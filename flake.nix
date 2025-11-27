{
  description = "APM Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            uv
            git
          ];

          shellHook = ''
            echo "Setting up development environment..."
            # Ensure the virtual environment exists and is up to date
            if [ -f "uv.lock" ]; then
                uv sync
            fi
            export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
          '';
        };

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScriptBin "apm" ''
            ${pkgs.uv}/bin/uv run apm "$@"
          ''}/bin/apm";
        };

        packages.default = pkgs.writeShellScriptBin "apm" ''
          ${pkgs.uv}/bin/uv run apm "$@"
        '';
      }
    );
}
