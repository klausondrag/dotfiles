today := `date '+%Y-%m-%d'`
base_folder := "./output"
output := base_folder + "/dotfiles_" + today
data := output + "/data"


hello:
    echo "Hello, World!"


create-package:
    rm -rf {{base_folder}}
    mkdir -p {{data}}
    cp -r ../../private {{data}}
    rsync -a --exclude 'output' ../dotfiles {{data}}/
    cp ./bootstrap.sh {{output}}


setup-basic: hostname setup-paths configure-gtk setup-profile-pic setup-wallpaper setup-apt upgrade install-fonts install-tools install-apps setup-zsh force-stow upgrade print-todo

setup-full: setup-basic dev-dependencies dev-docker dev-dotnet dev-py dev-rust latex


hostname:
    sudo hostname "k-c-t480"


setup-paths:
    mkdir -p ~/mine/src ~/mine/sync ~/mine/private ~/.local/bin
    ln -snf ~/Downloads ~/dl


setup-apt:
    sudo add-apt-repository -y --no-update universe
    sudo apt install nala


upgrade:
    sudo nala upgrade -y
    sudo nala autoremove -y
    flatpak update -y


upgrade-fw:
    sudo fwupdmgr update


upgrade-full: upgrade install-tools-nextgen-cargo upgrade-fw


echo-tools:
    # find info about running gui app: xwininfo from x11-utils
    echo "general: bat btop duf htop iftop jq neofetch nethogs radeontop rename s-tui xwininfo"
    echo "apt: exa ripgrep"
    echo "rust: bottom broot du-dust exa fd-find git-delta jql navi procs pipe-rename ripgrep tokei sad dog"


install-tools:
    sudo nala install -y curl ffmpeg git gnupg2 just make stow tree wget
    sudo nala install -y dconf-editor gnome-shell-extension-manager gnome-tweaks
    sudo nala install -y bat btop duf htop iftop jq neofetch nethogs radeontop rename s-tui

    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    sudo nala update
    sudo nala install -y httpie


install-tools-nextgen-apt:
    sudo nala install -y exa ripgrep


install-tools-nextgen-cargo:
    cargo install bottom broot du-dust exa fd-find git-delta jql navi procs pipe-rename ripgrep tokei
    cargo install --git https://github.com/ogham/dog dog
    cargo install --locked --all-features --git https://github.com/ms-jpq/sad --branch senpai
    # navi repo add https://github.com/denisidoro/cheats


install-apps:
    # Disable ipv6, otherwise Google Chrome doesn't work
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sudo systemctl restart systemd-networkd
    
    sudo nala install -y ./apps/*.deb    
    ./apps/jetbrains-toolbox-*
    cp ./apps/yt-dlp ~/.local/bin/
    chmod 755 ~/.local/bin/yt-dlp

    # Already provided by pop_os
    # sudo add-apt-repository ppa:touchegg/stable && sudo apt update
    # sudo apt install -y touchegg 

    sudo nala install -y cheese gparted mpv thunderbird wireshark
    sudo usermod -a -G wireshark $(whoami)
    flatpak install -y com.borgbase.Vorta com.calibre_ebook.calibre com.github.joseexposito.touche com.github.vikdevelop.photopea_app com.jgraph.drawio.desktop com.obsproject.Studio com.skype.Client com.spotify.Client com.usebottles.bottles fr.handbrake.ghb info.smplayer.SMPlayer io.github.kalaksi.Lightkeeper org.audacityteam.Audacity org.blender.Blender org.flameshot.Flameshot org.freecadweb.FreeCAD org.fritzing.Fritzing org.gimp.GIMP org.inkscape.Inkscape org.kde.kdenlive org.kicad.KiCad org.kde.krita org.phoenicis.playonlinux org.stellarium.Stellarium org.texstudio.TeXstudio org.videolan.VLC

    # wine
    if [ $(lsb_release --release | cut -f2) != "22.04" ]; then \
        echo "This script can only install wine for ubuntu 22.04. Please adjust script. Skipping."; \
    else \
        sudo dpkg --add-architecture i386; \
        sudo mkdir -pm755 /etc/apt/keyrings; \
        sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key; \
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources; \
        sudo nala update; \
        sudo nala install -y --install-recommends winehq-stable; \
    fi

    # Unity
    wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | sudo tee /usr/share/keyrings/Unity_Technologies_ApS.gpg > /dev/null
    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'
    sudo nala update
    sudo nala install -y unityhub


install-egpu:
    sudo cp ./apps/egpu-switcher-amd64 /opt/egpu-switcher
    sudo chmod 755 /opt/egpu-switcher
    sudo ln -s /opt/egpu-switcher /usr/bin/egpu-switcher
    sudo egpu-switcher enable

    
configure-gtk:
    gsettings set org.gnome.desktop.background show-desktop-icons false
    gsettings set org.gnome.desktop.calendar show-weekdate true
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'de'), ('ibus', 'libpinyin')]"
    gsettings set org.gnome.desktop.interface clock-format '24h'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-seconds true
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.privacy remember-recent-files false
    gsettings set org.gnome.desktop.sound event-sounds false
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.shell.window-switcher current-workspace-only false


setup-theme:
    gsettings set org.gnome.desktop.interface icon-theme "candy-icons"
    gsettings set org.gnome.desktop.interface gtk-theme "Skeuos-Orange-Dark"
    # gsettings set org.gnome.shell.extensions.user-theme "Orchis-Orange-Dark-Compact"


setup-wallpaper:
    gsettings set org.gnome.desktop.background picture-uri "file:///home/${USER}/mine/src/dotfiles/wallpaper/Among Trees (2).png"
    gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/${USER}/mine/src/dotfiles/wallpaper/Among Trees (2).png"
    gsettings set org.gnome.desktop.screensaver picture-uri "file:///home/${USER}/mine/src/dotfiles/wallpaper/Among Trees (2).png"
    # ❯ gsettings get org.gnome.desktop.screensaver picture-uri 
    # 'file:///usr/share/backgrounds/pop/kate-hazen-mort1mer.png'


setup-profile-pic:
    sudo sed -i "s/Icon=.*/Icon=\/home\/${USER}\/.face/g" "/var/lib/AccountsService/users/$USER"
    # The picture ~/.face is generated by setting it in settings -> users
    # and then copying it from `/var/lib/AccountsService/icons/$USER`.
    # The picture ~/.face will be linked/created by stow.


setup-zsh:
    sudo nala install -y zsh
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
    chsh -s $(which zsh)
    sudo chsh -s $(which zsh)


stow:
    # just _stow ./stow $HOME --restow
    just _stow ../dotfiles-secrets/stow $HOME --restow


unstow:
    just _stow --delete


force-stow:
    # rg --files --hidden stow | cut -d'/' -f3- | xargs -I "{}" rm -f "$HOME/{}"
    just stow


_stow source destination *OPTIONS:
    if [ -d "{{source}}" ]; then \
        stow {{OPTIONS}} --dir={{source}} --target={{destination}} $(ls {{source}}); \
    else \
        echo "Directory {{source}} does not exist. Skipping stow."; \
    fi


install-fonts:
    fc-cache -f -v


print-todo:
    echo "Finished. Remaining Todos:"
    echo "Reboot"
    echo "Configure KeePassXC"
    echo "Configure Audio"
    echo "Configure gnome extensions"
    echo "Configure Firefox"
    echo "Configure Chrome"
    echo "setup calendar in evolution"
    echo "just install-tools-nextgen-cargo or install-tools-nextgen-apt"


latex:
    sudo nala install -y texstudio texlive-full texlive-lang-german


dev-dependencies:
    sudo nala install -y build-essential gcc clang libssl-dev pkg-config gdb lcov pkg-config libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev libboost-dev libboost-program-options-dev libboost-system-dev libboost-math-dev libboost-thread-dev libboost-test-dev libboost-python-dev zlib1g-dev cmake python3 python3-pip apt-transport-https libc6 libgcc1 libgcc-s1 libgssapi-krb5-2 libicu70 liblttng-ust1 libssl3 libstdc++6 libunwind8 zlib1g


dev-docker:
    sudo nala install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo nala update
    sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo docker run hello-world


dev-py: dev-py-pyenv dev-py-poetry


dev-py-pyenv:
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    pyenv --version
    pyenv install 3.12


dev-py-poetry:
    sudo nala install pipx
    pipx install poetry
    poetry --version


dev-dotnet:
    sudo nala install -y dotnet-sdk-7.0

dev-rust:
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

