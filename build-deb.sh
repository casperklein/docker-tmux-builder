#!/bin/bash

set -ueo pipefail

APP=$(jq -er '.name'			< config.json | grep -oP '(?<=docker-).+?(?=-builder)') # docker-app-builder
VERSION=$(jq -er '.version'		< config.json)
TAG=$(jq -er '"\(.image):\(.version)"'	< config.json)

ARCH=$(dpkg --print-architecture)

DIR=${0%/*}
cd "$DIR"

echo "Building: $APP $VERSION"
echo
MAKEFLAGS=${MAKEFLAGS:-}
MAKEFLAGS=${MAKEFLAGS//--jobserver-auth=[[:digit:]],[[:digit:]]/}
docker build -t "$TAG" --build-arg MAKEFLAGS="${MAKEFLAGS:-}" --build-arg VERSION="$VERSION" .
echo

echo "Copy $APP $VERSION debian package to $PWD/"
docker run --rm -v "$PWD":/mnt/ "$TAG"
echo

dpkg -I "${APP}_${VERSION}-1_${ARCH}".deb
echo
