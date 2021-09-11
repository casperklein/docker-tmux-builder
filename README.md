# docker-tmux-builder

Builds a [tmux](https://github.com/tmux/tmux) debian package with [Docker](https://www.docker.com/). Supports `amd64`, `arm64` and `armhf` architecture.

When running **make**, tmux is build, packaged and copied to the current directory.

## Build tmux debian package
    make

## Build tmux debian package for older debian versions, e.g. Debian 10 (Buster)
    DEBIAN=10
    sed -i 's|^FROM.*|FROM debian:'$DEBIAN'-slim|' Dockerfile
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
