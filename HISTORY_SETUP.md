# ZSH History Management for Devcontainers

This configuration provides robust history management for zsh in devcontainer environments, with built-in corruption protection and recovery.

## Features

### 🔧 Automatic Corruption Detection & Repair
- Detects corrupted history files on shell startup
- Automatically repairs using `strings` to extract clean entries
- Creates timestamped backups of corrupted files

### 🔄 Container-Specific History
- Uses separate history files for containers vs host
- Prevents corruption from version differences
- Optional sync capability between host and container

### 📦 Smart History Options
- Large history size (10,000 entries in containers)
- Duplicate removal and optimization
- Immediate history writing with safe file locking
- Extended history format with timestamps

## Usage

### Manual Commands
```bash
# Fix corrupted history file
fix-history

# Create backup of current history
history-backup

# Sync with host history (if available)
sync-history

# Search history with arrow keys
# Type part of command + UP/DOWN arrows

# Search with Ctrl keys
# Ctrl+P = up, Ctrl+N = down
```

### History Files
- **Container**: `~/.zsh_history` (or `~/.zsh_history_container`)
- **Backups**: `~/.zsh_history.backup.TIMESTAMP`
- **Corrupted**: `~/.zsh_history.corrupt.TIMESTAMP`

## Configuration

### Container Detection
The configuration automatically detects devcontainer environments using:
- `/.dockerenv` file presence
- `$REMOTE_CONTAINERS` environment variable

### History Settings
```bash
# Container settings
HISTSIZE=10000
SAVEHIST=10000

# Host settings  
HISTSIZE=50000
SAVEHIST=50000
```

### Enabled Options
- `EXTENDED_HISTORY` - Timestamps
- `INC_APPEND_HISTORY` - Immediate writing
- `SHARE_HISTORY` - Share between sessions
- `HIST_IGNORE_ALL_DUPS` - Remove duplicates
- `HIST_FCNTL_LOCK` - Safe file locking

## Plugins

### Active History Plugins
1. **zsh-autosuggestions** - Fish-like suggestions
2. **zsh-history-substring-search** - Search with arrows
3. **zsh-syntax-highlighting** - Command highlighting

### Key Bindings
- `↑` / `↓` - History substring search
- `Ctrl+P` / `Ctrl+N` - History substring search
- `→` / `End` - Accept suggestion

## Troubleshooting

### If History Gets Corrupted
1. The system will auto-detect and repair on next shell start
2. Manual repair: `fix-history`
3. Start fresh: `echo "# Fresh start $(date)" > ~/.zsh_history`

### If History Seems Lost
1. Check backup files: `ls ~/.zsh_history*`
2. Restore from backup: `cp ~/.zsh_history.backup.YYYYMMDD_HHMMSS ~/.zsh_history`

### Performance Issues
- Large history files can slow down shell startup
- Use `history-backup` then truncate if needed
- Consider reducing `HISTSIZE` if too slow

## Best Practices

1. **Regular Backups**: Use `history-backup` before major changes
2. **Clean Exits**: Use `exit` command instead of closing terminal abruptly
3. **Monitor Size**: Check history file size periodically
4. **Sync Carefully**: Only use `sync-history` when needed

## Files Modified
- `~/.zshrc` - Main configuration
- `/workspaces/devcontainer-root/dotfiles/.zshrc` - Template
- `/workspaces/devcontainer-root/.devcontainer/devcontainer.json` - Container config

## Version
Updated: October 1, 2025
Compatible with: zsh 5.9+, Oh My Zsh
