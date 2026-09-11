#!/bin/zsh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

GREEN='\033[0;32m'
RESET='\033[0m'

echo "${GREEN}.dotfile installation STARTING${RESET}"

IS_CONTAINER=false
if [ -n "$REMOTE_CONTAINERS" ] || [ -f "/.dockerenv" ] || [ -n "$WSL_DISTRO_NAME" ]; then
    IS_CONTAINER=true
fi

IS_MAC=false
if [[ "$(uname)" == "Darwin" ]]; then
    IS_MAC=true
fi

# Essential and development tools
echo "Checking essential tools..."
TOOLS_TO_INSTALL=""
BREW_TOOLS="zsh curl wget jq git unzip terraform docker gh aws-cli python3 tmux"
APT_TOOLS="zsh curl wget jq git unzip terraform docker.io gh awscli python3 tmux"

# Check and install required tools
if $IS_MAC; then
    for tool in zsh curl wget jq git unzip terraform docker gh aws-cli python3 tmux; do
        if ! command -v $tool &> /dev/null; then
            TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL $tool"
        fi
    done

    if [ -n "$TOOLS_TO_INSTALL" ]; then
        echo "Installing missing tools via brew: $TOOLS_TO_INSTALL"
        brew install $TOOLS_TO_INSTALL 2>/dev/null || echo "Some tools may require manual installation"
    fi
else
    for tool in zsh curl wget jq git unzip terraform docker gh awscli python3 tmux; do
        if ! command -v $tool &> /dev/null; then
            TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL $tool"
        fi
    done

    if [ -n "$TOOLS_TO_INSTALL" ]; then
        echo "Installing missing tools: $TOOLS_TO_INSTALL"
        sudo apt-get update && sudo apt-get install -y $TOOLS_TO_INSTALL 2>/dev/null || echo "Some tools may require manual installation"
    fi

    # Docker on Linux may need additional setup
    if command -v docker &> /dev/null && ! groups | grep -q docker; then
        echo "Note: Docker installed but you may need to run: sudo usermod -aG docker \$USER"
    fi
fi

echo "Essential tools setup complete"

cp ./.gitconfig ~

# Fonts - host Mac only
if [ -f ./fonts.sh ]; then
    chmod +x ./fonts.sh
    ./fonts.sh
fi

# oh-my-zsh installation
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    if command -v curl &> /dev/null; then
        timeout 60 sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || echo "oh-my-zsh install timed out or failed"
    else
        echo "curl not found, skipping oh-my-zsh installation"
    fi
fi

# Copy .zshrc
if [ ! -f "$HOME/.zshrc" ] && [ -f ./.zshrc ]; then
    cp ./.zshrc ~
    echo "Copied .zshrc to home directory"
fi

# zsh plugins - only if oh-my-zsh is installed
if [ -d "$HOME/.oh-my-zsh" ]; then
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    mkdir -p "$ZSH_CUSTOM/plugins"

    if command -v git &> /dev/null; then
        if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
            timeout 30 git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || echo "Failed to clone zsh-autosuggestions"
        fi

        if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
            timeout 30 git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || echo "Failed to clone zsh-syntax-highlighting"
        fi

        if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
            timeout 30 git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search" 2>/dev/null || echo "Failed to clone zsh-history-substring-search"
        fi
    else
        echo "git not found, skipping oh-my-zsh plugins"
    fi
fi

# fzf
if command -v git &> /dev/null; then
    if [ ! -d "$HOME/.fzf" ]; then
        timeout 30 git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null || echo "Failed to clone fzf"
        if [ -f ~/.fzf/install ]; then
            ~/.fzf/install --all --no-update-rc 2>/dev/null || true
        fi
    fi
fi

# Terraform autocomplete
if command -v terraform >/dev/null 2>&1; then
    echo "Setting up Terraform autocomplete..."
    terraform -install-autocomplete 2>/dev/null || true
fi

echo ".dotfile installation COMPLETE"
echo -e "\e[0m"
