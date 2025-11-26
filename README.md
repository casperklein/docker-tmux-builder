# docker-tmux-builder

Builds a [tmux](https://github.com/tmux/tmux) Debian 13 package with [Docker](https://www.docker.com/). Tested architectures: `amd64`

When running **make**, tmux is build, packaged and copied to the current directory.

## Prepare

    git clone https://github.com/casperklein/docker-tmux-builder
    cd docker-tmux-builder

## Build tmux debian package

    make

## Install tmux debian package

    make install

## Copy tmux.conf to /etc/tmux.conf and tmux.pin to /etc/apt/preferences.d/tmux

    make copy-conf

## Bash completion

Get completion file from [here](https://raw.githubusercontent.com/scop/bash-completion/refs/heads/main/completions/tmux).

## Uninstall tmux

    make uninstall

## Cleanup build environment

    make clean
