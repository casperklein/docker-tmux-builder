FROM	debian:10-slim

ENV	GIT_USER="tmux"
ENV	GIT_REPO="tmux"
ENV	GIT_COMMIT="3.1c"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/releases/download/$GIT_COMMIT/$GIT_REPO-$GIT_COMMIT.tar.gz"

ENV	PACKAGES="file checkinstall dpkg-dev gcc make libevent-dev libncurses5-dev"
ENV	PACKAGES_CLEAN=""

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ENV	DEBIAN_FRONTEND=noninteractive
RUN	echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/buster-backports.list \
&&	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Download source
WORKDIR	/$GIT_REPO
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_REPO-$GIT_COMMIT.tar.gz && rm /$GIT_REPO-$GIT_COMMIT.tar.gz

# Build tmux
ARG	MAKEFLAGS=""
RUN	./configure
RUN	make

# Create debian package with checkinstall
ENV	APP="tmux"
ENV	MAINTAINER="casperklein@docker-tmux-builder"
ENV	GROUP="admin"
ARG	VERSION
RUN	echo 'tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.' > description-pak \
&&	checkinstall -y --install=no			\
			--pkgname=$APP			\
			--pkgversion=$VERSION		\
			--maintainer=$MAINTAINER	\
			--pkggroup=$GROUP

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv ${APP}_*.deb /mnt"]
