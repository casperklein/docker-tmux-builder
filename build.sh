#!/bin/bash

set -ueo pipefail

USER=$(grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2)
NAME=$(grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2)
VERSION=$(grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2)
TAG="$USER/$NAME:$VERSION"

NAME=${NAME//-builder}
DEBIAN="$(</etc/debian_version)"
DEBIAN=${DEBIAN:-10}

DIR=${0%/*}
cd "$DIR"

echo "Building: $NAME $VERSION"
echo
docker build -t "$TAG" --build-arg debian="$DEBIAN" .

echo "Copy $NAME $VERSION debian package to $(pwd)/"
docker run --rm -v "$(pwd)":/mnt/ "$TAG"
echo
