today := `date '+%Y-%m-%d'`
base_folder := "./output"
output := base_folder + "/" + today
data := output + "/data"

hello:
    echo "Hello, World!"

create-package:
    rm -rf {{base_folder}}
    mkdir -p {{data}}
    cp -r ../../private {{data}}
    rsync -a --exclude 'output' ../bootstrap {{data}}/
    cp -r ../dotfiles {{data}}
    cp ./bootstrap.sh {{output}}

complete-setup: create-symlinks upgrade install-tools install-apps configure-gtk

create-symlinks:
    ln -snf ~/Downloads ~/dl

upgrade:
    sudo add-apt-repository -y --no-update universe
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y

install-tools:
    sudo apt install -y tree make just git curl wget ripgrep htop stow
    sudo apt install -y dconf-editor gnome-tweaks gnome-shell-extension-manager

install-apps:
    sudo apt install -y ./apps/*.deb
    # sudo apt install -y thunderbird
    ./apps/jetbrains-toolbox-*
    
configure-gtk:
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'de'), ('ibus', 'libpinyin')]"
    gsettings set org.gnome.desktop.interface clock-format '24h'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-seconds true
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.sound event-sounds false
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

setup-zsh:
    sudo apt install -y zsh
    if [ -d "$HOME/.oh-my-zsh" ]; then \
        echo "~/.oh-my-zsh already exists. Not re-installing oh-my-zsh."; \
    else \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
    fi

    if [ -d "$HOME/.fzf" ]; then \
        echo "~/.fzf already exists. Not re-installing fzf."; \
    else \
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; \
        ~/.fzf/install; \
    fi

setup-dotfiles:
    echo "todo"
    

stow:
    just _stow --restow

unstow:
    just _stow --delete

force-stow:
    git checkout HEAD
    just _stow --adopt --stow
    git checkout HEAD
    just _stow --restow

_stow *OPTIONS:
    stow {{OPTIONS}} --dir=./stow --target=$HOME nautilus
