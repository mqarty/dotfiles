#!/bin/bash

# Skip font installation in devcontainers - fonts must be on the host
if [ -n "$REMOTE_CONTAINERS" ] || [ -f "/.dockerenv" ]; then
    echo "Skipping font install in devcontainer - install fonts on host Mac instead"
    exit 0
fi

declare -a fonts=(
  Hack
  RobotoMono
  SpaceMono
)

version=$(curl -s 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' | jq -r '.name')
if [ -z "$version" ] || [ "$version" = "null" ]; then
  version="v3.2.1"
fi
echo "latest version: $version"

# Mac vs Linux font directory
if [[ "$(uname)" == "Darwin" ]]; then
    fonts_dir="$HOME/Library/Fonts"
else
    fonts_dir="${HOME}/.local/share/fonts"
    # Install fontconfig on Linux
    apt install -y fontconfig
fi

mkdir -p "$fonts_dir"

for font in "${fonts[@]}"; do
  zip_file="${font}.zip"
  download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
  echo "Downloading $download_url"
  wget "$download_url"
  unzip -o "$zip_file" -d "$fonts_dir"
  rm "$zip_file"
done

find "$fonts_dir" -name 'Windows Compatible' -delete

# Rebuild font cache on Linux only
if [[ "$(uname)" != "Darwin" ]]; then
    fc-cache -fv
fi
