FROM	debian:13-slim

ARG	GIT_USER="tmux"
ARG	GIT_REPO="tmux"
ARG	GIT_COMMIT="3.6"
# ARG	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"
ARG	GIT_ARCHIVE="https://github.com/${GIT_USER}/${GIT_REPO}/releases/download/${GIT_COMMIT}/tmux-${GIT_COMMIT}.tar.gz"
ARG	ARCHIVE="tmux-${GIT_COMMIT}.tar.gz"

# ARG	PACKAGES="file checkinstall dpkg-dev gcc make libevent-dev libncurses-dev autoconf automake pkg-config yacc"
ARG     PACKAGES="gcc checkinstall libevent-dev yacc libncurses-dev wget"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ARG	DEBIAN_FRONTEND=noninteractive
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Download source
WORKDIR /build
RUN	wget "$GIT_ARCHIVE" \
&&	tar xzvf "$ARCHIVE" \
&&	rm "$ARCHIVE"

#! workdir must be tmux-3.X; just "tmux" makes checkinstall behave weird.
#! tmux binary is put in /usr/local/tmux instead of /usr/local/bin/tmux
WORKDIR "/build/tmux-$GIT_COMMIT"

# Build tmux
ARG	MAKEFLAGS=""
# only needed when building from "git clone"
# RUN	./autogen.sh
RUN	./configure \
&&	make

# Create debian package with checkinstall
ENV	APP="tmux"
ARG	GROUP="admin"
ARG	MAINTAINER="casperklein@docker-tmux-builder"
ARG	VERSION="unknown"
RUN	echo 'tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.' > description-pak \
# fstrans=no since debian12 -->  https://bugs.launchpad.net/ubuntu/+source/checkinstall/+bug/976380
&&	checkinstall -y --fstrans=no                                        \
			--install=no                                        \
			--pkgname=$APP                                      \
			--pkgversion=$VERSION                               \
			--maintainer=$MAINTAINER                            \
			--pkggroup=$GROUP                                   \
			--requires="libc6, libevent-core-2.1-7, libtinfo6"

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv ${APP}_*.deb /mnt"]

LABEL	org.opencontainers.image.description="Builds a tmux debian package"
LABEL	org.opencontainers.image.source="https://github.com/casperklein/docker-tmux-builder/"
LABEL	org.opencontainers.image.title="docker-tmux-builder"
LABEL	org.opencontainers.image.version="$VERSION"
