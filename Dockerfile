FROM	debian:11-slim

ARG	GIT_USER="tmux"
ARG	GIT_REPO="tmux"
ARG	GIT_COMMIT="3.3a"
ARG	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ARG	PACKAGES="file checkinstall dpkg-dev gcc make libevent-dev libncurses5-dev autoconf automake pkg-config bison"
ARG	PACKAGES_CLEAN=""

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ARG	DEBIAN_FRONTEND=noninteractive
RUN	echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/buster-backports.list \
&&	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Download source
WORKDIR	/$GIT_REPO
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Build tmux
ARG	MAKEFLAGS=""
RUN	./autogen.sh \
&&	./configure \
&&	make

# Create debian package with checkinstall
ARG	APP="tmux"
ARG	GROUP="admin"
ARG	MAINTAINER="casperklein@docker-tmux-builder"
ARG	VERSION="unknown"
RUN	echo 'tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.' > description-pak \
&&	checkinstall -y --install=no			\
			--pkgname=$APP			\
			--pkgversion=$VERSION		\
			--maintainer=$MAINTAINER	\
			--pkggroup=$GROUP

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv ${APP}_*.deb /mnt"]

LABEL	org.opencontainers.image.description="Builds a tmux debian package"
LABEL	org.opencontainers.image.source="https://github.com/casperklein/docker-tmux-builder/"
LABEL	org.opencontainers.image.title="docker-tmux-builder"
LABEL	org.opencontainers.image.version="$VERSION"
