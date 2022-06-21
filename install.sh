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

dotsroot="${0%/*}"
IFS=$'\n' set -- $(find "$dotsroot" -path "$dotsroot/.git" -prune -o ! -wholename "$0" -a ! -wholename "$dotsroot/README.md" -type f -printf '%P\n')

while (( $# )); do
    dest="$HOME/$1"
    destdir="${dest%/*}"

    src="$dotsroot/$1"
    srcdir="${src%/*}"

    perm=$(stat -c %a "$srcdir")
    install -Ddvm$perm "$destdir"

    relative_src=$(realpath -L --relative-to="$destdir" "$src")

    ln -sfv "$relative_src" "$dest"

    shift
done
