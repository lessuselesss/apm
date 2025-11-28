#!/bin/bash
# Setup script for Gemini CLI runtime
# Creates a wrapper for gemini-cli from nix-ai-tools

set -euo pipefail

# Get the directory of this script for sourcing common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/setup-common.sh"

# Configuration
VANILLA_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --vanilla)
            VANILLA_MODE=true
            shift
            ;;
        *)
            # For Gemini, we don't currently support version selection
            shift
            ;;
    esac
done

setup_gemini() {
    log_info "Setting up Gemini CLI runtime..."
    
    # Ensure APM runtime directory exists
    ensure_apm_runtime_dir
    
    local runtime_dir="$HOME/.apm/runtimes"
    local gemini_wrapper="$runtime_dir/gemini"
    
    # Check if running in a Nix environment with gemini-cli available
    local gemini_binary=""
    if command -v gemini >/dev/null 2>&1; then
        gemini_binary=$(which gemini)
        log_info "Found gemini-cli at: $gemini_binary"
    else
        log_error "gemini-cli not found. Please ensure you're running this from the APM development environment."
        log_info "Run 'nix develop' in the APM project directory first."
        exit 1
    fi
    
    # Create wrapper script that calls gemini from Nix
    log_info "Creating Gemini CLI wrapper script..."
    cat > "$gemini_wrapper" <<EOF
#!/bin/bash
# Gemini CLI wrapper script created by APM
# This wrapper ensures gemini-cli is called from the Nix environment

# Try to use the gemini binary directly if available
if command -v "$gemini_binary" >/dev/null 2>&1; then
    exec "$gemini_binary" "\$@"
else
    # Fallback: try to find gemini in the Nix store
    if command -v gemini >/dev/null 2>&1; then
        exec gemini "\$@"
    else
        echo "Error: gemini-cli not found. Please run from APM development environment." >&2
        exit 1
    fi
fi
EOF
    
    chmod +x "$gemini_wrapper"
    
    # Verify installation
    verify_binary "$gemini_wrapper" "Gemini CLI"
    
    # Update PATH
    ensure_path_updated
    
    # Test installation
    log_info "Testing Gemini CLI installation..."
    if "$gemini_wrapper" --version >/dev/null 2>&1; then
        local version=$("$gemini_wrapper" --version)
        log_success "Gemini CLI runtime installed successfully! Version: $version"
    else
        log_warning "Gemini CLI wrapper installed but version check failed. It may still work."
    fi
    
    # Show next steps
    echo ""
    log_info "Next steps:"
    if [[ "$VANILLA_MODE" == "false" ]]; then
        echo "1. Get your Gemini API key from Google AI Studio: https://aistudio.google.com/app/apikey"
        echo "2. Set your API key: export GEMINI_API_KEY=your_key_here"
        echo "3. Then run with APM: apm run start --runtime=gemini"
        echo ""
        log_success "✨ Gemini CLI installed and ready to use!"
        echo "   - Google Gemini provides powerful AI assistance for coding tasks"
        echo "   - Interactive mode: gemini"
        echo "   - Direct prompts: gemini \"your prompt\""
    else
        echo "1. Get your Gemini API key from Google AI Studio: https://aistudio.google.com/app/apikey"
        echo "2. Set your API key: export GEMINI_API_KEY=your_key_here"
        echo "3. Then run: gemini --help"
    fi
}

# Run setup if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_gemini "$@"
fi
