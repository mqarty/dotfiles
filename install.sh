#!/bin/bash

echo -e "\e[32m"

echo ".dotfile installation STARTING"

# zsh should already be installed in the Dockerfile, but ensure it's there
if ! command -v zsh &> /dev/null; then
    echo "Installing zsh..."
    apt-get update && apt-get install -y zsh
fi

cat bashrc.additions >> ~/.bashrc

cp ./.gitconfig ~

# Install Nerd Fonts
./fonts.sh

# oh-my-zsh & plugins - check if already installed from Dockerfile
if [ ! -d "/root/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh (not found in image)..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
else
    echo "oh-my-zsh already installed, updating..."
    zsh -c 'omz update' || true
fi

# Copy zshrc (this will have user customizations)
cp ./.zshrc ~

########################################################################################################################
#### set agnoster as theme, this came from https://gist.github.com/corentinbettiol/21a6d4e942a0ee58d51acb7996697a88
#### in vscode settings for devcontainer (not for User or Workspace), Search for terminal.integrated.fontFamily value, and set it to "Roboto Mono for Powerline" (or any of those: https://github.com/powerline/fonts#font-families font families).
# save current zshrc
mv ~/.zshrc ~/.zshrc.bak

sudo sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)" -- \
    -t agnoster

# remove newly created zshrc
rm -f ~/.zshrc
# restore saved zshrc
mv ~/.zshrc.bak ~/.zshrc
# update theme
sed -i '/^ZSH_THEME/c\ZSH_THEME="agnoster"' ~/.zshrc
########################################################################################################################

# Install zsh plugins if not already installed from Dockerfile
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    zsh -c 'git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    zsh -c 'git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search" ]; then
    echo "Installing zsh-history-substring-search..."
    zsh -c 'git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search'
fi

# Install fzf for fuzzy autocomplete if not already installed
if [ ! -d "~/.fzf" ]; then
    echo "Installing fzf for fuzzy finding..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
    ~/.fzf/install --all --no-update-rc 2>/dev/null || true
else
    echo "fzf already installed"
fi

# Enable Terraform autocomplete if terraform is installed
if command -v terraform >/dev/null 2>&1; then
    echo "Setting up Terraform autocomplete..."
    terraform -install-autocomplete 2>/dev/null || true
fi

echo ".dotfile installation COMPLETE"
echo -e "\e[0m"
