#!/bin/bash

echo -e "\e[32m"

echo ".dotfile installation STARTING"

apt-get install -y zsh

cat bashrc.additions >> ~/.bashrc

cp ./.gitconfig ~

# # powerline fonts for zsh agnoster theme
# git clone https://github.com/powerline/fonts.git
# cd fonts
# ./install.sh
# cd .. && rm -rf fonts

# Install Nerd Fonts
./fonts.sh

# oh-my-zsh & plugins
# Install using official method
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
# Update to latest version
zsh -c 'omz update' || true
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

zsh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
zsh -c 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'
zsh -c 'git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search'

# Install fzf for fuzzy autocomplete
echo "Installing fzf for fuzzy finding..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
~/.fzf/install --zsh --no-update-rc 2>/dev/null || true

# Enable Terraform autocomplete if terraform is installed
if command -v terraform >/dev/null 2>&1; then
    echo "Setting up Terraform autocomplete..."
    terraform -install-autocomplete || true
fi

echo ".dotfile installation COMPLETE"
echo -e "\e[0m"
