ARG	version="10"
FROM	debian:$version-slim

ARG	MAKEFLAGS=""

ENV	USER="casperklein"
ENV	NAME="tmux-builder"
ENV	VERSION="3.1c"
ENV	APP="tmux"
ENV	GROUP="admin"

ENV	TMUX_DEV=""
ENV	TMUX_SHA256="918f7220447bef33a1902d4faff05317afd9db4ae1c9971bef5c787ac6c88386"
ENV	TMUX="tmux-$VERSION$TMUX_DEV"
ENV	TMUX_RELEASE="https://github.com/tmux/tmux/releases/download/$VERSION/$TMUX.tar.gz"

ENV	PACKAGES="gcc make libevent-dev libncurses5-dev"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y --no-install-recommends install $PACKAGES

# Add/verify tmux source
ADD	$TMUX_RELEASE /
RUN	HASH=$(sha256sum $TMUX.tar.gz) && [ "${HASH:0:64}" == "$TMUX_SHA256" ] && echo "$TMUX.tar.gz: valid " || { echo -e "Stored Hash: $TMUX_SHA256\nFile Hash:   $HASH"; exit 1; }

# Build tmux
RUN	tar xzvf $TMUX.tar.gz
WORKDIR	$TMUX
RUN	./configure
RUN	make
RUN	echo 'tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.' > description-pak

# Copy root filesystem
COPY	rootfs /

# Create debian package with checkinstall
RUN	MACHINE=$(uname -m);	\
	case "$MACHINE" in	\
	x86_64)			\
		ARCH="amd64"	\
		;;		\
	aarch64)		\
		ARCH="arm64"	\
		;;		\
	*)			\
		ARCH="armhf"	\
		;;		\
	esac;			\
	apt-get -y --no-install-recommends install file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_$ARCH.deb
RUN	checkinstall -y --install=no			\
			--pkgname=$APP			\
			--pkgversion=$VERSION$TMUX_DEV	\
			--maintainer=$USER@$NAME	\
			--pkggroup=$GROUP

# Move tmux debian package to /mnt on container start
CMD	mv ${APP}_$VERSION$TMUX_DEV-1_*.deb /mnt
