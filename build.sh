#!/bin/bash

set -ueo pipefail

VERSION="$(</etc/debian_version)"
VERSION=${VERSION:-10}
DIR=${0%/*}
cd "$DIR" || exit 1

USER=casperklein
NAME=tmux-builder
TAG=$(grep TMUX_VERSION= Dockerfile | cut -d'"' -f2)
DEV=$(grep TMUX_DEV= Dockerfile | cut -d'"' -f2)
IMAGE="$USER/$NAME:$TAG$DEV"

echo "Building tmux $TAG$DEV on Debian $VERSION"
echo
docker build -t "$IMAGE" --build-arg version="$VERSION" .
echo

echo "Copy tmux $TAG$DEV debian package to $(pwd)/"
docker run --rm -v "$(pwd)":/mnt/ "$IMAGE"
echo
