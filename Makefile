# all targets are phony (no files to check)
.PHONY: default build clean copy-conf install uninstall

SHELL := /bin/bash

USER := $(shell grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2)
NAME := $(shell grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2)
APP := $(shell grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2 | cut -d'-' -f1)
VERSION := $(shell grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2)

ARCH := $(shell						\
	MASCHINE=$$(uname -m);				\
	if [ "$$MASCHINE" == "x86_64" ]; then		\
		echo "amd64";				\
	elif [ "$$MASCHINE" == "aarch64" ]; then	\
		echo "arm64";				\
	else						\
		echo "armhf";				\
	fi						\
)

default: build

build:
	@./build-deb.sh "$(debian)" "$(makeflags)"

clean:
	rm -f "$(APP)_$(VERSION)"-1_*.deb
	docker rmi "$(USER)/$(NAME):$(VERSION)"

copy-conf:
	cp tmux.conf /etc

install:
	dpkg -i "$(APP)_$(VERSION)"-1_$(ARCH).deb

uninstall:
	apt-get purge "$(APP)"
