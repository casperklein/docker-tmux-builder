ARG	version=10
FROM	debian:$version-slim

ENV	USER="casperklein"
ENV	NAME="tmux-builder"
ENV	VERSION="3.0a"
ENV	APP="tmux"
ENV	GROUP="admin"

ENV	TMUX_DEV=""
ENV	TMUX_SHA256="4ad1df28b4afa969e59c08061b45082fdc49ff512f30fc8e43217d7b0e5f8db9"
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
RUN	./configure && make
RUN	echo 'tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.' > description-pak

# Copy root filesystem
COPY	rootfs /

# Create debian package with checkinstall
RUN	MASCHINE=$(uname -m) \
;	[ "$MASCHINE" == "x86_64" ] && ARCH=amd64 \
||	[ "$MASCHINE" == "aarch64" ] && ARCH=amd64 \
||	ARCH="armhf" \
;	apt-get install -y --no-install-recommends file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_$ARCH.deb
RUN	checkinstall -y --install=no \
			--pkgname=$APP \
			--pkgversion=$VERSION$TMUX_DEV \
			--maintainer=$USER@$NAME \
			--pkggroup=$GROUP

# Move tmux debian package to /mnt on container start
CMD	mv ${APP}_$VERSION$TMUX_DEV-1_*.deb /mnt
