#!/bin/bash

# Skip font installation in devcontainers - fonts must be on the host
if [ -n "$REMOTE_CONTAINERS" ] || [ -f "/.dockerenv" ] || [ -n "$WSL_DISTRO_NAME" ]; then
    echo "Skipping font install in devcontainer/WSL - install fonts on host instead"
    exit 0
fi

# Mac vs Linux font directory
if [[ "$(uname)" == "Darwin" ]]; then
    fonts_dir="$HOME/Library/Fonts"
else
    fonts_dir="${HOME}/.local/share/fonts"
    # Install fontconfig on Linux
    if command -v sudo &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y fontconfig 2>/dev/null || true
    else
        apt-get update && apt-get install -y fontconfig 2>/dev/null || true
    fi
fi

mkdir -p "$fonts_dir"
state_dir="$HOME/.cache/dotfiles/fonts_installed"
mkdir -p "$state_dir"

# Use bundled RobotoMono font if available
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "$SCRIPT_DIR/RobotoMono.zip" ]; then
    echo "Installing bundled RobotoMono font..."
    if command -v unzip &> /dev/null; then
        unzip -o "$SCRIPT_DIR/RobotoMono.zip" -d "$fonts_dir" >/dev/null 2>&1 || echo "Failed to extract RobotoMono"
        echo "v3.2.1" > "$state_dir/RobotoMono.version"
        find "$fonts_dir" -name 'Windows Compatible' -delete 2>/dev/null || true
    else
        echo "unzip not found, cannot install bundled fonts"
    fi
else
    echo "RobotoMono.zip not found in $(dirname "$0")"
fi

# Rebuild font cache on Linux only
if [[ "$(uname)" != "Darwin" ]]; then
    if command -v fc-cache &> /dev/null; then
        fc-cache -fv 2>/dev/null || true
    fi
fi

echo "Font installation complete"
