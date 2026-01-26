# dotfiles

As advised by Christof Marti at https://github.com/microsoft/vscode-remote-release/issues/8436#issuecomment-1531018498
VSCode has support for cloning a repo of dotfiles.

And, related docs > https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories

## Secrets Management

The `.zshrc` automatically sources `~/.zshrc.secrets` if it exists. This allows you to keep sensitive credentials (API keys, tokens, etc.) out of version control.

### Setup

1. Copy the example template:
   ```bash
   cp .zshrc.secrets.example ~/.zshrc.secrets
   ```

2. Make it secure:
   ```bash
   chmod 600 ~/.zshrc.secrets
   ```

3. Edit `~/.zshrc.secrets` and add your actual credentials

**Important**: Never commit `.zshrc.secrets` - only the `.zshrc.secrets.example` template should be in git.

## ZSH History Management

The `.zshrc` includes automatic corruption detection and repair for history files in devcontainers.

### Quick Fix for Corrupted History

If you see a corrupted history file error:
```bash
# Option 1: Auto-fix (built into .zshrc, runs on next shell restart)
exec zsh

# Option 2: Manual fix
fix-history

# Option 3: Start fresh
echo "# Fresh history $(date)" > ~/.zsh_history
```

For detailed information about history management, see [HISTORY_SETUP.md](./HISTORY_SETUP.md).
