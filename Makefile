default: build

build:
	./build.sh

clean:
	rm -f tmux_*.deb
	TAG=$$(grep TMUX_VERSION= Dockerfile | cut -d'"' -f2) && \
	DEV=$$(grep TMUX_DEV= Dockerfile | cut -d'"' -f2) && \
	IMAGE="casperklein/tmux-builder:$$TAG$$DEV" && \
	docker rmi $$IMAGE

copy-conf:
	cp tmux.conf /etc

install:
	dpkg -i tmux_*.deb

uninstall:
	apt-get purge tmux
