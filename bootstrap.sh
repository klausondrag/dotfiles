#!/usr/bin/env bash

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable
set -o pipefail # don't hide errors within pipes

if [ -d "$HOME/mine" ]; then
  echo "~/mine already exist. Please delete it first. Exiting."
  exit 1
fi

echo "Creating folders under ~/mine"
mkdir -p ~/mine/src ~/mine/sync
cp -r ./data/private ~/mine/
cp -r ./data/dotfiles ~/mine/src/

echo "Installing KeePassXC and just"
sudo apt update
sudo apt install -y keepassxc just

echo "Configuring keyboard input sources"
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'de')]"

echo "Finished. Please execute the following line to contine:"
echo "cd ~/mine/src/dotfiles; just hello"

