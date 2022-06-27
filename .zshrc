typeset -Ug path
path+=(~/bin(N-/) ~/.local/bin(N-/))

typeset -Ug fpath
fpath+=(/usr/share/zsh/site-functions(N-/))

typeset -Ug manpath
manpath+=(/usr/share/man(N-/))

typeset -Ug cdpath
cdpath+=(~ ..(N-/) ~/github(N-/))


if (( $+commands[tmux] && ! $+TMUX && $+SSH_CONNECTION )); then
    tmux has-session && exec tmux attach
    exec tmux new
fi

TRAPUSR1() { rehah }

autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

urlencode() {
    if [[ "$1" == '-d' ]]; then
        cat | sed 's/+/ /g; s/\%/\\x/g' | xargs -rd\\n printf '%b\n'
    else
        local c
        cat | fold -b1 - | while read -r c; do
            case $c in
                [a-zA-Z0-9.~_-]) printf '%c' "$c" ;;
                ' ') printf + ;;
                *) printf '%%%.2X' "'$c" ;;
            esac
        done
        echo
    fi
}

bindkey -e

ttyctl -f

reset_broken_terminal() {
    printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8'
}

precmd_functions+=(reset_broken_terminal)

clear-screen-and-scrollback() {
    echoti civis >"$TTY"
    printf '%b' '\e[H\e[2J' >"$TTY"
    zle .reset-prompt
    zle -R
    printf '%b' '\e[3J' >"$TTY"
    echoti cnorm >"$TTY"
}

zle -N clear-screen-and-scrollback
bindkey '^L' clear-screen-and-scrollback

HISTSIZE=10000
SAVEHIST=$((HISTSIZE * 365))

bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

setopt EXTENDED_GLOB
setopt NULL_GLOB

autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars ' _-./;@?'
zstyle ':zle:*' word-style unspecified

() {
    local rc=$HOME/.antigen/antigen.zsh
    if [[ ! -f $rc ]]; then
        curl -SsfLo $rc --create-dirs git.io/antigen
    fi
    source $rc

    antigen bundles <<EOBUNDLES
        zsh-users/zaw
        zsh-users/zsh-autosuggestions
        zsh-users/zsh-completions
        zsh-users/zsh-syntax-highlighting

        sorin-ionescu/prezto modules/command-not-found
        sorin-ionescu/prezto modules/completion
        sorin-ionescu/prezto modules/history

        mafredri/zsh-async

        Tarrasch/zsh-autoenv

        vtj-ttanaka/pure@main
EOBUNDLES

    antigen apply

    export AUTOENV_HANDLE_LEAVE=1

    PURE_PROMPT_SYMBOL='›'
    PURE_PROMPT_VICMD_SYMBOL='‹'
    if [[ $TERM == linux ]]; then
        PURE_PROMPT_SYMBOL='>'
        PURE_PROMPT_VICMD_SYMBOL='<'
        PURE_GIT_DOWN_ARROW='pull'
        PURE_GIT_UP_ARROW='push'
        PURE_GIT_STASH_SYMBOL='stash'
    fi
}

autoload -Uz run-help
if (( $+aliases[run-help] )); then
    unalias run-help
fi

mkcd() { install -Ddm755 "$1" && cd "$1" }

cd-undo() {
    popd
    zle .reset-prompt
}

cd-parent() {
    if [[ $PWD == / ]]; then
        return
    fi
    pushd ..
    zle .reset-prompt
}

zle -N cd-parent
zle -N cd-undo
bindkey '[1;3A' cd-parent
bindkey '[1;3B' cd-undo

alias history='fc -lDi'
alias relogin='exec $SHELL -l'
alias ls='ls -Xv --color=auto --group-directories-first'
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias mkdir='mkdir -v'
alias grep='grep --color=auto'

if (( $+commands[anyenv] )); then
    () {
        local prefix=$(anyenv root)
        path+=($prefix/bin)
        source <(anyenv init -)
        local vf=$prefix/envs/tfenv/version
        if (( $+commands[tfenv] )) && [[ -f $vf ]]; then
            autoload -U +X bashcompinit && bashcompinit
            local v=$(< $vf)
            complete -o nospace -C $prefix/envs/tfenv/versions/$v/terraform terraform
        fi
    }
fi

if (( $+commands[aws] )); then
    unset AWS_PROFILE
fi

if (( $+commands[brew] )); then
    () {
        local prefix=$(brew --prefix)
        path+=($prefix/bin(N-/) $prefix/sbin(N-/))
        fpath+=($prefix/share/zsh/site-functions(N-/))
        manpath+=($prefix/share/man(N-/))
    }
    _brew() {
        command brew "$@" || return
        if (( $@[(I)install] || $@[(I)uninstall] || $@[(I)upgrade] )); then
            pkill -USR1 zsh
        fi
    }
    alias brew=_brew
fi

if (( $+commands[cargo] )); then
    () {
        local prefix=${CARGO_HOME:-$HOME/.cargo}
        path+=($prefix/bin(N-/))
    }
fi

if (( $+commands[emacsclient] )); then
    alias emacs='emacsclient -t'
fi

if (( $+commands[gcloud] )); then
    export CLOUDSDK_ACTIVE_CONFIG_NAME=null
fi

if (( $+commands[gh] )); then
    source <(gh completion -s zsh)
fi

if (( $+commands[git] )); then
    autoload -Uz run-help-git
fi

if (( $+commands[go] )); then
    () {
        local prefix=${GOPATH:-$HOME/go}
        path+=($prefix/bin(N-/))
    }
fi

if (( $+commands[gpg] )); then
    export GPG_TTY=$(tty)
fi

if (( $+commands[ip] )); then
    autoload -Uz run-help-ip
fi

if (( $+commands[kubectl] )); then
    unset KUBECONFIG
    source <(kubectl completion zsh)
fi

if (( $+commands[nnn] )); then
    local plugdir=$HOME/.config/nnn/plugins
    if [[ ! -f $plugdir/getplugs ]]; then
        curl -SsfL https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
    fi

    typeset -TUg NNN_BMS nnn_bms ';'
    nnn_bms=()

    typeset -TUg NNN_PLUG nnn_plug ';'
    nnn_plug=(f:finder p:preview-tui)

    export NNN_OPTS=ado \
           NNN_OPENER=$plugdir/nuke \
           NNN_ORDER= \
           NNN_COLORS='1234' \
           NNN_FCOLORS='c1e2272e006033f7c6d6abc4' \
           NNN_TRASH=${commands[trash]:+1} \
           NNN_TMPFILE='/tmp/.lastd'

    if (( $+DISPLAY )); then
        export GUI=1
    fi

    alias nnn='nnn -Tv'
fi

if (( $+commands[openssl] )); then
    autoload -Uz run-help-openssl
fi

if (( $+commands[stern] )); then
    source <(stern --completion zsh)
fi

if (( $+commands[sudo] )); then
    autoload -Uz run-help-sudo
fi

if (( $+commands[trash] )); then
    alias rm='trash -v'
fi

if (( $+commands[qmk] )); then
    :
fi

zcompilex() {
    local src=$1 zwc=$1.zwc
    [[ ! -f $zwc || $src -nt $zwc ]] && zcompile $src
}

zcompilex ~/.zshrc

() {
    while (( $# )); do
        zcompilex $1
        source $1
        shift
    done
} ~/.zshrc.*~*.zwc

if (( $+builtins[zprof] )); then
    zprof
fi
