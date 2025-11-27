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

            if [ -z "$GITHUB_COPILOT_PAT" ]; then
                echo "⚠️  GITHUB_COPILOT_PAT is not set. You may need it for some features."
                echo "   Get one at https://github.com/settings/personal-access-tokens/new"
            fi
          '';
        };

        apps = {
          default = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "apm" ''
              ${pkgs.uv}/bin/uv run apm "$@"
            ''}/bin/apm";
          };

          init = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "apm-init" ''
              ${pkgs.uv}/bin/uv run apm init "$@"
            ''}/bin/apm-init";
          };

          runtime-setup = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "apm-runtime-setup" ''
              ${pkgs.uv}/bin/uv run apm runtime setup "$@"
            ''}/bin/apm-runtime-setup";
          };

          compile = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "apm-compile" ''
              ${pkgs.uv}/bin/uv run apm compile "$@"
            ''}/bin/apm-compile";
          };

          install = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "apm-install" ''
              ${pkgs.uv}/bin/uv run apm install "$@"
            ''}/bin/apm-install";
          };

          deps-list = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "apm-deps-list" ''
              ${pkgs.uv}/bin/uv run apm deps list "$@"
            ''}/bin/apm-deps-list";
          };

          run = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "apm-run" ''
              ${pkgs.uv}/bin/uv run apm run "$@"
            ''}/bin/apm-run";
          };
        };

        packages.default = pkgs.writeShellScriptBin "apm" ''
          ${pkgs.uv}/bin/uv run apm "$@"
        '';
      }
    );
}
