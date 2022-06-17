#!/bin/bash

if [[ "${0##*/}" != 'install.sh' ]]; then
    if [[ -d $HOME/.dots ]]; then
        mv "$HOME/.dots{,.old}"
    fi
    install -dm700 "$HOME/.dots"
    curl -SsfLo /tmp/dots.zip https://github.com/vtj-ttanaka/dots/archive/refs/heads/develop.zip
    unzip /tmp/dots.zip -d "$HOME/.dots"
    exec "$HOME/.dots/install.sh"
fi

srcdir="${0%/*}"
IFS= set -- $(find "$srcdir" -path "$srcdir/.git" -prune -o ! -wholename "$0" -type f -printf '%P\n')

while (( $# )); do
    src=$(realpath -L --relative-to=$HOME "$srcdir/$1")
    dest="$HOME/$1"
    install -Ddvm755 "${dest%/*}"
    ln -sfv "$src" "$dest"
    shift
done
