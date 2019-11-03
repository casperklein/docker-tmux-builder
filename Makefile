# all targets are phony (no files to check)
.PHONY: default build clean copy-conf install uninstall

default: build

build:
	./build.sh

clean:
	USER=$$(grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2) && \
	NAME=$$(grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2) && \
	VERSION=$$(grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2) && \
	rm -f tmux_$$VERSION-1*.deb && \
	docker rmi $$USER/$$NAME:$$VERSION

copy-conf:
	cp tmux.conf /etc

install:
	dpkg -i tmux_*.deb

uninstall:
	apt-get purge tmux
