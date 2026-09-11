#!/bin/zsh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

GREEN='\033[0;32m'
RESET='\033[0m'

echo "${GREEN}.dotfile installation STARTING${RESET}"

IS_CONTAINER=false
if [ -n "$REMOTE_CONTAINERS" ] || [ -f "/.dockerenv" ]; then
    IS_CONTAINER=true
fi

IS_MAC=false
if [[ "$(uname)" == "Darwin" ]]; then
    IS_MAC=true
fi

# zsh - container has it in Dockerfile, Mac should have it via brew
if ! command -v zsh &> /dev/null; then
    if $IS_MAC; then
        brew install zsh
    else
        apt-get update && apt-get install -y zsh
    fi
fi

cat bashrc.additions >> ~/.bashrc
cp ./.gitconfig ~

# Fonts - host Mac only
./fonts.sh

# oh-my-zsh (skipped - install manually if needed: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")
# if [ ! -d "$HOME/.oh-my-zsh" ]; then
#     echo "Installing oh-my-zsh..."
#     timeout 60 sh -c "$(timeout 30 curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || echo "oh-my-zsh install timed out"
# else
#     echo "oh-my-zsh already installed, updating..."
#     timeout 30 git -C "$HOME/.oh-my-zsh" pull --rebase || echo "oh-my-zsh update timed out"
# fi

# cp ./.zshrc ~  # commented out since oh-my-zsh is skipped

# zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    timeout 30 git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || echo "Failed to clone zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    timeout 30 git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || echo "Failed to clone zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    timeout 30 git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search" || echo "Failed to clone zsh-history-substring-search"
fi

# fzf
if [ ! -d "$HOME/.fzf" ]; then
    timeout 30 git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || echo "Failed to clone fzf"
    ~/.fzf/install --all --no-update-rc 2>/dev/null || true
fi

# Terraform autocomplete
if command -v terraform >/dev/null 2>&1; then
    echo "Setting up Terraform autocomplete..."
    terraform -install-autocomplete 2>/dev/null || true
fi

echo ".dotfile installation COMPLETE"
echo -e "\e[0m"
