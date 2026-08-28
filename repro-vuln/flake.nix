{
  # Auxiliary dev shell pinning the *vulnerable* libnixexpr that devenv
  # 2.2.2 shipped (flake.lock -> cachix/nix @ 59407321, tip of the
  # `devenv-2.34` branch, libnixexprc 2.34.8), plus gcc for compiling
  # sizeof/offsetof probes against the vendored internal headers.
  # See devenv-nix-backend/tests/README.eval-readonly-uaf.md for the full
  # runbook (both sides of the repro).
  inputs.nix.url = "github:cachix/nix/59407321a92f7d34d4a53e38959294007c0bc37a";
  inputs.nixpkgs.follows = "nix/nixpkgs";

  outputs =
    {
      self,
      nix,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.pkg-config
          pkgs.gcc
          nix.packages.${system}.nix.dev
        ];
      };
    };
}
