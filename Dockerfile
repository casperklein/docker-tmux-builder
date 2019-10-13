ARG	version=10
FROM    debian:$version-slim as build

ENV	TMUX_VERSION="3.0"
ENV	TMUX_DEV="-rc5"
ENV	TMUX="tmux-$TMUX_VERSION$TMUX_DEV"
ENV	TMUX_RELEASE="https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/$TMUX.tar.gz"

ENV	PACKAGES="gcc make libevent-dev libncurses5-dev"

# Install packages
RUN     apt-get update \
&&	apt-get -y --no-install-recommends install $PACKAGES

# Build tmux
ADD	$TMUX_RELEASE /
RUN	tar xzvf $TMUX.tar.gz
WORKDIR	$TMUX
RUN	./configure && make

# Copy root filesystem
COPY	rootfs /

# Create debian package with checkinstall
RUN	apt-get install -y --no-install-recommends file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_amd64.deb
RUN	checkinstall -y --install=no \
			--pkgname=tmux \
			--pkgversion=$TMUX_VERSION$TMUX_DEV \
			--maintainer=casperklein@docker-tmux-builder
RUN	mv tmux_*.deb /

# Build final image
FROM	busybox:latest
COPY	--from=build /tmux_*.deb /
CMD	mv /tmux*.deb /mnt
