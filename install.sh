#!/bin/bash

if [[ "${0##*/}" != 'install.sh' ]]; then
    if [[ -d $HOME/.dots ]]; then
        mv "$HOME/.dots" "$HOME/.dots.old"
    fi
    curl -SsfLo /tmp/dots.zip https://github.com/vtj-ttanaka/dots/archive/refs/heads/develop.zip
    unzip -o /tmp/dots.zip -d /tmp
    mv /tmp/dots-develop "$HOME/.dots"
    exec "$HOME/.dots/install.sh"
fi

srcdir="${0%/*}"
IFS=$'\n' set -- $(find "$srcdir" -path "$srcdir/.git" -prune -o ! -wholename "$0" -a ! -wholename "$srcdir/README.md" -type f -printf '%P\n')

while (( $# )); do
    dest="$HOME/$1"
    destdir="${dest%/*}"
    src=$(realpath -L --relative-to="$destdir" "$srcdir/$1")
    install -Ddvm755 "$destdir"
    ln -sfv "$src" "$dest"
    shift
done
