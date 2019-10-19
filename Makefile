# all our targets are phony (no files to check).
.PHONY: default build clean copy-conf install uninstall

default: build

build:
	./build.sh

clean:
	TAG=$$(grep TMUX_VERSION= Dockerfile | cut -d'"' -f2) && \
	DEV=$$(grep TMUX_DEV= Dockerfile | cut -d'"' -f2) && \
	IMAGE="casperklein/tmux-builder:$$TAG$$DEV" && \
	rm -f tmux_$$IMAGE_1*.deb && \
	docker rmi $$IMAGE

copy-conf:
	cp tmux.conf /etc

install:
	dpkg -i tmux_*.deb

uninstall:
	apt-get purge tmux
