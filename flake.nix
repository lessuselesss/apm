{
  description = "APM Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      sops-nix,
      nix-ai-tools,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ai-tools = nix-ai-tools.packages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              python3
              uv
              nodejs24
              git
              sops
              age
            ]
            ++ [
              # AI coding tools from nix-ai-tools
              ai-tools.claude-code
              ai-tools.opencode
              ai-tools.gemini-cli
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

          load-secrets = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "load-secrets" ''
              # Hybrid Secret Loading Logic
              # Priority 1: Local .env file (for solo development)
              # Priority 2: Sops-encrypted secrets (for team collaboration)

              # Check for .env first
              if [ -f .env ]; then
                # Source .env and export all variables
                set -a
                source .env
                set +a
                echo "# Loaded from .env (local development)" >&2
              elif [ -f secrets.yaml ]; then
                # Try to load from sops
                if command -v ${pkgs.sops}/bin/sops &> /dev/null; then
                  # Export secrets from sops
                  GITHUB_COPILOT_PAT=$(${pkgs.sops}/bin/sops -d --extract '["github_copilot_pat"]' secrets.yaml 2>/dev/null || echo "")
                  GITHUB_APM_PAT=$(${pkgs.sops}/bin/sops -d --extract '["github_apm_pat"]' secrets.yaml 2>/dev/null || echo "")
                  GITHUB_TOKEN=$(${pkgs.sops}/bin/sops -d --extract '["github_token"]' secrets.yaml 2>/dev/null || echo "")
                  GITHUB_HOST=$(${pkgs.sops}/bin/sops -d --extract '["github_host"]' secrets.yaml 2>/dev/null || echo "")
                  
                  # Output export statements
                  [ -n "$GITHUB_COPILOT_PAT" ] && echo "export GITHUB_COPILOT_PAT='$GITHUB_COPILOT_PAT'"
                  [ -n "$GITHUB_APM_PAT" ] && echo "export GITHUB_APM_PAT='$GITHUB_APM_PAT'"
                  [ -n "$GITHUB_TOKEN" ] && echo "export GITHUB_TOKEN='$GITHUB_TOKEN'"
                  [ -n "$GITHUB_HOST" ] && echo "export GITHUB_HOST='$GITHUB_HOST'"
                  
                  if [ -n "$GITHUB_COPILOT_PAT" ]; then
                    echo "# Loaded from sops (team secrets)" >&2
                  else
                    echo "# ⚠️  No secrets found in secrets.yaml" >&2
                  fi
                else
                  echo "# ⚠️  sops not available" >&2
                fi
              else
                echo "# ⚠️  No .env or secrets.yaml found" >&2
                echo "#   For local dev: cp .env.example .env" >&2
                echo "#   For team secrets: Set up age key and use 'sops secrets.yaml'" >&2
              fi
            ''}/bin/load-secrets";
          };

          # AI Coding Tools from nix-ai-tools (wrapped as apps)
          claude-code = {
            type = "app";
            program = "${ai-tools.claude-code}/bin/claude-code";
          };
          opencode = {
            type = "app";
            program = "${ai-tools.opencode}/bin/opencode";
          };
          gemini-cli = {
            type = "app";
            program = "${ai-tools.gemini-cli}/bin/gemini";
          };
        };

        packages.default = pkgs.writeShellScriptBin "apm" ''
          ${pkgs.uv}/bin/uv run apm "$@"
        '';
      }
    );
}
