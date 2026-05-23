FROM	debian:13-slim

ARG	GIT_USER="tmux"
ARG	GIT_REPO="tmux"
ARG	GIT_COMMIT="3.6a"
# ARG	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"
ARG	GIT_ARCHIVE="https://github.com/${GIT_USER}/${GIT_REPO}/releases/download/${GIT_COMMIT}/tmux-${GIT_COMMIT}.tar.gz"
ARG	ARCHIVE="tmux-${GIT_COMMIT}.tar.gz"

ARG	PACKAGES="gcc libevent-dev yacc libncurses-dev wget make"

# Package ENVs
ENV	APP="tmux"
ARG	VERSION
ARG	PRIORITY="optional"
ARG	SECTION="admin"
ARG	MAINTAINER="docker-tmux-builder"
ARG	TARGETARCH
ARG	DEPENDS="libc6, libevent-core-2.1-7, libtinfo6"
ARG	DESCRIPTION="tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen."

# Build ENVs
ARG	INCLUDE_DOCS="1"      # Include docs? [0|1]
ARG	BUILD_DIR="/build"    # Root build directory
ARG	PACKAGE_DIR="package" # Package subdirectory

SHELL	["/bin/bash", "-e", "-o", "pipefail", "-c"]

# Install packages
ARG	DEBIAN_FRONTEND=noninteractive
RUN <<EOF
	apt-get update
	apt-get -y upgrade
	apt-get -y install $PACKAGES
	rm -rf /var/lib/apt/lists/*
EOF

# Download source
WORKDIR "${BUILD_DIR}"
RUN <<EOF
	wget --no-verbose "$GIT_ARCHIVE"
	tar xzvf "$ARCHIVE"
	rm "$ARCHIVE"
EOF

# Build tmux
WORKDIR "$BUILD_DIR/$APP-$GIT_COMMIT"
ARG	MAKEFLAGS=""
RUN <<EOF
	# ./autogen.sh # only needed when building from "git clone"
	./configure
	make
EOF

# Run 'make install', capture FS changes and prepare package in $BUILD_DIR/$PACKAGE_DIR
COPY	capture.sh /usr/local/bin/
RUN	capture.sh make install

# Build .deb package
RUN	dpkg-deb --build "$BUILD_DIR/$PACKAGE_DIR" /${APP}_$VERSION-1_"$TARGETARCH".deb

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv /${APP}_*.deb /mnt"]

LABEL	org.opencontainers.image.description="Builds a tmux debian package"
LABEL	org.opencontainers.image.source="https://github.com/casperklein/docker-tmux-builder/"
LABEL	org.opencontainers.image.title="docker-tmux-builder"
LABEL	org.opencontainers.image.version="$VERSION"
