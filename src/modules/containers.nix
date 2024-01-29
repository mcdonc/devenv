{ pkgs, config, lib, self, ... }:

let
  projectName = name:
    if config.name == null
    then throw ''You need to set `name = "myproject";` or `containers.${name}.name = "mycontainer"; to be able to generate a container.''
    else config.name;
  types = lib.types;
  envContainerName = builtins.getEnv "DEVENV_CONTAINER";

  nix2containerInput = config.lib.getInput {
    name = "nix2container";
    url = "github:nlewo/nix2container";
    attribute = "containers";
    follows = [ "nixpkgs" ];
  };
  nix2container = nix2containerInput.packages.${pkgs.stdenv.system};
  mk-shell-bin = config.lib.getInput {
    name = "mk-shell-bin";
    url = "github:rrbutani/nix-mk-shell-bin";
    attribute = "containers";
  };
  shell = mk-shell-bin.lib.mkShellBin { drv = config.shell; nixpkgs = pkgs; };
  intrbash = "${pkgs.bashInteractive}/bin/bash";
  mkEntrypoint = cfg: pkgs.writeScript "entrypoint" ''
    #!${intrbash}

    export PATH=/bin

    source ${shell.envScript}

    # expand any envvars before exec
    cmd="`echo "$@"|${pkgs.envsubst}/bin/envsubst`"

    ${intrbash} -c "$cmd"
  '';
  user = "user";
  group = "user";
  uid = "1000";
  gid = "1000";
  homedir = "/env";

  mkTemp = (pkgs.runCommand "tmp" { } ''
    mkdir -p $out/tmp
  '');

  mkUser = (pkgs.runCommand "user" { } ''
    mkdir -p $out${homedir}
    cp -R ${self}/* $out${homedir}/

    mkdir -p $out/etc/pam.d

    echo "root:x:0:0:System administrator:/root:${intrbash}" > \
          $out/etc/passwd
    echo "${user}:x:${uid}:${gid}::${homedir}:${intrbash}" >> \
          $out/etc/passwd

    echo "root:!x:::::::" > $out/etc/shadow
    echo "${user}:!x:::::::" >> $out/etc/shadow

    echo "root:x:0:" > $out/etc/group
    echo "${group}:x:${gid}:" >> $out/etc/group

    cat > $out/etc/pam.d/other <<EOF
    account sufficient pam_unix.so
    auth sufficient pam_rootok.so
    password requisite pam_unix.so nullok sha512
    session required pam_unix.so
    EOF

    touch $out/etc/login.defs
  '');

  mkDerivation = cfg: nix2container.nix2container.buildImage {
    name = cfg.name;
    tag = cfg.version;
    initializeNixDatabase = true;
    nixUid = lib.toInt uid;
    nixGid = lib.toInt gid;

    copyToRoot = [
      (pkgs.buildEnv {
        name = "root";
        paths = [
          pkgs.coreutils-full
          pkgs.bashInteractive
          pkgs.su
          pkgs.sudo
        ];
        pathsToLink = "/bin";
      })
      mkUser
      mkTemp
    ];

    perms = [
      {
        path = mkUser;
        regex = "${homedir}";
        mode = "0744";
        uid = lib.toInt uid;
        gid = lib.toInt gid;
        uname = user;
        gname = group;
      }
      {
        path = mkTemp;
        regex = "/tmp";
        mode = "1777";
        uid = 0;
        gid = 0;
        uname = "root";
        gname = "root";
      }
    ];

    config = {
      Entrypoint = cfg.entrypoint;
      User = "${user}";
      WorkingDir = "${homedir}";
      Env = lib.mapAttrsToList
        (name: value:
          "${name}=${lib.escapeShellArg (toString value)}"
        )
        config.env ++ [ "HOME=${homedir}" "USER=${user}" ];
      Cmd = [ cfg.startupCommand ];
    };
  };

  # <registry> <args>
  mkCopyScript = cfg: pkgs.writeScript "copy-container" ''
    container=$1
    shift

    if [[ "$1" == false ]]; then
      registry=${cfg.registry}
    else
      registry="$1"
    fi
    shift

    dest="''${registry}${cfg.name}:${cfg.version}"

    if [[ $# == 0 ]]; then
      args=(${toString cfg.defaultCopyArgs})
    else
      args=("$@")
    fi

    echo
    echo "Copying container $container to $dest"
    echo

    ${nix2container.skopeo-nix2container}/bin/skopeo --insecure-policy copy "nix:$container" "$dest" "''${args[@]}"
  '';
  containerOptions = types.submodule ({ name, config, ... }: {
    options = {
      name = lib.mkOption {
        type = types.nullOr types.str;
        description = "Name of the container.";
        defaultText = "top-level name or containers.mycontainer.name";
        default = "${projectName name}-${name}";
      };

      version = lib.mkOption {
        type = types.nullOr types.str;
        description = "Version/tag of the container.";
        default = "latest";
      };

      copyToRoot = lib.mkOption {
        type = types.nullOr (types.either types.path (types.listOf types.path));
        description = "Add a path to the container. Defaults to the whole git repo.";
        default = self;
        defaultText = "self";
      };

      startupCommand = lib.mkOption {
        type = types.nullOr (types.either types.str types.package);
        description = "Command to run in the container.";
        default = null;
      };

      entrypoint = lib.mkOption {
        type = types.listOf types.anything;
        description = "Entrypoint of the container.";
        default = [ (mkEntrypoint config) ];
        defaultText = lib.literalExpression "[ entrypoint ]";
      };

      defaultCopyArgs = lib.mkOption {
        type = types.listOf types.str;
        description =
          ''
            Default arguments to pass to `skopeo copy`.
            You can override them by passing arguments to the script.
          '';
        default = [ ];
      };

      registry = lib.mkOption {
        type = types.nullOr types.str;
        description = "Registry to push the container to.";
        default = "docker://";
      };

      isBuilding = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Set to true when the environment is building this container.";
      };

      derivation = lib.mkOption {
        type = types.package;
        internal = true;
        default = mkDerivation config;
      };

      copyScript = lib.mkOption {
        type = types.package;
        internal = true;
        default = mkCopyScript config;
      };

      dockerRun = lib.mkOption {
        type = types.package;
        internal = true;
        default = pkgs.writeScript "docker-run" ''
          #!${intrbash}

          docker run -it ${config.name}:${config.version} "$@"
        '';
      };
    };
  });
in
{
  options = {
    containers = lib.mkOption {
      type = types.attrsOf containerOptions;
      default = { };
      description = "Container specifications that can be built, copied and ran using `devenv container`.";
    };

    container = {
      isBuilding = lib.mkOption {
        type = types.bool;
        default = false;
        description = "Set to true when the environment is building a container.";
      };
    };
  };

  config = lib.mkMerge [
    {
      container.isBuilding = envContainerName != "";

      containers.shell = {
        name = lib.mkDefault "shell";
        startupCommand = lib.mkDefault intrbash;
      };

      containers.processes = {
        name = lib.mkDefault "processes";
        startupCommand = lib.mkDefault config.procfileScript;
      };
    }
    (if envContainerName == "" then { } else {
      containers.${envContainerName}.isBuilding = true;
    })
    (lib.mkIf config.container.isBuilding {
      devenv.root = lib.mkForce "${homedir}";
    })
  ];
}
