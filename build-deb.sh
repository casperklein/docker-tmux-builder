#!/bin/bash

set -ueo pipefail

DIR=${0%/*}
cd "$DIR"

APP=$(jq -er '.name'			< config.json | grep -oP '(?<=docker-).+?(?=-builder)') # docker-app-builder
VERSION=$(jq -er '.version'		< config.json)
TAG=$(jq -er '"\(.image):\(.version)"'	< config.json)

ARCH=$(dpkg --print-architecture)

echo "Building: $APP $VERSION"
echo
MAKEFLAGS=${MAKEFLAGS:-}
MAKEFLAGS=${MAKEFLAGS//--jobserver-auth=[[:digit:]],[[:digit:]]/}
docker build -t "$TAG" --build-arg MAKEFLAGS="${MAKEFLAGS:-}" --build-arg VERSION="$VERSION" --provenance=false "$@" .
echo

echo "Copy $APP $VERSION debian package to $PWD/${APP}_${VERSION}-1_${ARCH}.deb"
docker run --rm -v "$PWD":/mnt/ "$TAG"
echo

echo "Package information:"
echo
dpkg -I "${APP}_${VERSION}-1_${ARCH}".deb
echo
dpkg -c "${APP}_${VERSION}-1_${ARCH}".deb
echo
