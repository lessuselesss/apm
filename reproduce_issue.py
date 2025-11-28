
import os
import sys
import shutil
import tempfile
from pathlib import Path
from click.testing import CliRunner
from apm_cli.cli import cli

def test_reproduction():
    runner = CliRunner()
    with tempfile.TemporaryDirectory() as tmp_dir:
        os.chdir(tmp_dir)
        print(f"Running in {tmp_dir}")
        
        # Test 1: init without flags (should NOT create flake.nix currently, but user wants it to be prompted)
        print("\n--- Test 1: init without flags ---")
        result = runner.invoke(cli, ["init", "--yes"])
        print(f"Exit code: {result.exit_code}")
        if Path("flake.nix").exists():
            print("flake.nix created (Unexpected for current behavior, but desired if default)")
        else:
            print("flake.nix NOT created (Expected for current behavior)")
            
        # Clean up for next test
        if Path("apm.yml").exists():
            os.remove("apm.yml")
            
        # Test 2: init with --with-flake (should create flake.nix)
        print("\n--- Test 2: init with --with-flake ---")
        result = runner.invoke(cli, ["init", "--yes", "--with-flake"])
        print(f"Exit code: {result.exit_code}")
        if result.exit_code != 0:
            print(f"Error output: {result.output}")
            
        if Path("flake.nix").exists():
            print("flake.nix created (Success)")
            with open("flake.nix") as f:
                content = f.read()
                if "path:/home/lessuseless" in content:
                    print("flake.nix content looks like the fallback inline content (hardcoded path)")
                else:
                    print("flake.nix content looks like it came from template")
        else:
            print("flake.nix NOT created (FAILURE)")

if __name__ == "__main__":
    test_reproduction()
