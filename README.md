# docker-tmux-builder

Builds a [tmux](https://github.com/tmux/tmux) Debian 12 package with [Docker](https://www.docker.com/). Supports `amd64`, `arm64` and `armhf` architecture.

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

See `bash_completion_tmux.sh` for details.

## Uninstall tmux

    make uninstall

## Cleanup build environment

    make clean
