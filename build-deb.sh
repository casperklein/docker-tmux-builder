#!/bin/bash

set -ueo pipefail

USER=$(grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2)
NAME=$(grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2)
VERSION=$(grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2)
TAG="$USER/$NAME:$VERSION"

MASCHINE=$(uname -m)
case "$MASCHINE" in
	x86_64)
		ARCH="amd64"
	       ;;
	aarch64)
		ARCH="arm64"
		;;
	*)
		ARCH="armhf"
		;;
esac

NAME=${NAME//-builder}

[ -n "${1:-}" ] && DEBIAN_VERSION="--build-arg version=$1"

DIR=${0%/*}
cd "$DIR"

echo "Building: $NAME $VERSION"
echo
MAKEFLAGS=${MAKEFLAGS:-}
MAKEFLAGS=${MAKEFLAGS//--jobserver-auth=[[:digit:]],[[:digit:]]/}
docker build -t "$TAG" ${DEBIAN_VERSION:-} --build-arg MAKEFLAGS="${MAKEFLAGS:-}" .
echo

echo "Copy $NAME $VERSION debian package to $PWD/"
docker run --rm -v "$PWD":/mnt/ "$TAG"
echo

dpkg -I "${NAME}_${VERSION}"-1_${ARCH}.deb
echo
