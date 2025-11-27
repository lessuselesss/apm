# Secret Management Guide

APM uses a **hybrid secret management approach** that supports both local development and team collaboration.

## Quick Start (Local Development)

For solo development, use the traditional `.env` file approach:

```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your tokens
# GITHUB_COPILOT_PAT=your_token_here
# GITHUB_APM_PAT=your_token_here
```

The `.env` file is gitignored and will be automatically loaded by direnv.

## Team Collaboration with sops-nix

For team secret sharing, use sops-encrypted secrets:

### First-Time Setup

1. **Generate your age key** (one-time setup):
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. **Share your public key** with the team:
   ```bash
   # Your public key is in the age-keygen output
   # It looks like: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

3. **Team admin adds your key** to `.sops.yaml`:
   ```yaml
   creation_rules:
     - path_regex: secrets\.yaml$
       age: >-
         age1your_key_here,
         age1teammate1_key_here,
         age1teammate2_key_here
   ```

### Using Encrypted Secrets

1. **Edit encrypted secrets** (requires your age key in `.sops.yaml`):
   ```bash
   sops secrets.yaml
   ```

2. **Secrets are automatically loaded** by direnv when you enter the directory.

3. **Priority order**:
   - ✅ `.env` file (if exists) - **highest priority**
   - ✅ `secrets.yaml` (sops-encrypted) - **fallback**

## How It Works

The `.envrc` file implements the hybrid approach:

1. **Check for `.env`**: If found, load it (local development)
2. **Fallback to sops**: If no `.env`, decrypt `secrets.yaml` (team secrets)
3. **Warning**: If neither exists, show setup instructions

## Secret Files

| File | Purpose | Committed to Git? |
|------|---------|-------------------|
| `.env.example` | Template with all required variables | ✅ Yes |
| `.env` | Your local secrets | ❌ No (gitignored) |
| `.sops.yaml` | sops configuration (age keys) | ✅ Yes |
| `secrets.yaml` | Encrypted team secrets | ✅ Yes (encrypted) |

## Required Secrets

- **`GITHUB_COPILOT_PAT`** - Required for GitHub Copilot runtime
  - Get from: https://github.com/settings/personal-access-tokens/new
  - Scopes: User-scoped with Copilot CLI access

- **`GITHUB_APM_PAT`** - Optional, for private APM modules
  - Fine-grained PAT with repository read access

- **`GITHUB_TOKEN`** - Optional, for Codex runtime
  - User PAT with models read access

- **`GITHUB_HOST`** - Optional, for GitHub Enterprise
  - Defaults to `github.com`

## Troubleshooting

### "No secrets found"
- **Local dev**: Copy `.env.example` to `.env`
- **Team secrets**: Ensure your age key is in `.sops.yaml` and `secrets.yaml` is encrypted

### "sops: failed to decrypt"
- Your age key is not in `.sops.yaml`
- Ask team admin to add your public key

### "command not found: sops"
- Enter the nix dev shell: `nix develop` or use direnv
- sops and age are available in the dev environment
