# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/antigen.zsh

antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
    git
    docker
    pip
    python
    virtualenv
    command-not-found
    colored-man-pages
    gnu-utils
    history

    zsh-users/zsh-completions
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-history-substring-search
EOBUNDLES

# antigen bundle mafredri/zsh-async
antigen theme romkatv/powerlevel10k

antigen apply

DEFAULT_USER="klaus"


# up_arrow
bindkey "^[[A" history-substring-search-up

# down_arrow
bindkey "^[[B" history-substring-search-down

# ctrl+left_arrow
bindkey "^[[1;5D" backward-word
bindkey "\eOd" backward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[5D" backward-word
bindkey "\e\e[D" backward-word

# ctrl+right_arrow
bindkey "^[[1;5C" forward-word
bindkey "\eOc" forward-word
bindkey "\e[1;5C" forward-word
bindkey "\e[5C" forward-word
bindkey "\e\e[C" forward-word


# variables
export ZSH=/home/klaus/.oh-my-zsh
export BROWSER=/usr/bin/firefox
export EDITOR=subl
export PATH=/home/klaus/.local/bin:$PATH
export PATH=$PATH:/usr/local/go/bin:/home/klaus/go/bin
# for bigger histories
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE


# functions and aliases
mkcd() { 
    mkdir -p "$@" || return
    shift "$(( $# - 1 ))"
    cd -- "$1"
}

cl() {
    cd -- "$1"
    ll
}

fb() {
    if [ -f "$1" ]; then
        xdg-open "$(dirname "$1")"
    else
        xdg-open "$1"
    fi
}

alias j="just"
# alias ll="ls -al --color"
alias ll="exa --all --long --header --icons --git"


# startup 
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# py poetry
mkdir -p ~/.zfunc
poetry completions zsh > ~/.zfunc/_poetry
fpath+=~/.zfunc
autoload -Uz compinit && compinit


source /home/klaus/.config/broot/launcher/bash/br
eval "$(navi widget zsh)"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
