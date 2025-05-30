devenvFlake: { flake-parts-lib, lib, inputs, ... }: {
  options.perSystem = flake-parts-lib.mkPerSystemOption ({ config, pkgs, system, ... }:

    let
      devenvType = (devenvFlake.lib.mkEval {
        inherit inputs pkgs;
        modules = [
          ({ config, ... }: {
            config = {
              _module.args.pkgs = pkgs.appendOverlays config.overlays;
              # Add flake-parts-specific config here if necessary
            };
          })
        ] ++ config.devenv.modules;
      }).type;

      shellPrefix = shellName: if shellName == "default" then "" else "${shellName}-";
    in

    {
      options.devenv.modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        description = ''
          Extra modules to import into every shell.
          Allows flakeModules to add options to devenv for example.
        '';
        default = [
          devenvFlake.flakeModules.readDevenvRoot
        ];
      };
      options.devenv.shells = lib.mkOption {
        type = lib.types.lazyAttrsOf devenvType;
        description = ''
          The [devenv.sh](https://devenv.sh) settings, per shell.

          Each definition `devenv.shells.<name>` results in a value for
          [`devShells.<name>`](flake-parts.html#opt-perSystem.devShells).

          Define `devenv.shells.default` for the default `nix develop`
          invocation - without an argument.
        '';
        example = lib.literalExpression ''
          {
            # create devShells.default
            default = {
              # devenv settings, e.g.
              languages.elm.enable = true;
            };
          }
        '';
        default = { };
      };
      config.devShells = lib.mapAttrs (_name: devenv: devenv.shell) config.devenv.shells;

      config.packages =
        lib.concatMapAttrs
          (shellName: devenv:
            (lib.concatMapAttrs
              (containerName: container:
                { "${shellPrefix shellName}container-${containerName}" = container.derivation; }
              )
              devenv.containers
            ) // {
              "${shellPrefix shellName}devenv-up" = devenv.procfileScript;
              "${shellPrefix shellName}devenv-test" = devenv.test;
            }
          )
          config.devenv.shells;
    });

  # the extra parameter before the module make this module behave like an
  # anonymous module, so we need to manually identify the file, for better
  # error messages, docs, and deduplication.
  _file = __curPos.file;
}
