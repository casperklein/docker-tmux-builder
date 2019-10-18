default: build

build:
	./build.sh

clean:
	rm -f tmux_*.deb

copy-conf:
	cp tmux.conf /etc

install:
	dpkg -i tmux_*.deb

uninstall:
	apt-get purge tmux
