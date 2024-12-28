# all targets are phony (no files to check)
.PHONY: default build clean copy-conf install uninstall

SHELL := /bin/bash

APP := $(shell jq -er '.name' < config.json | grep -oP '(?<=docker-).+?(?=-builder)')
VERSION := $(shell jq -er '.version' < config.json)
TAG := $(shell jq -er '"\(.image):\(.version)"' < config.json)

ARCH := $(shell dpkg --print-architecture)

default: build

build:
	@./build-deb.sh

clean:
	@rm -f "$(APP)_$(VERSION)"-1_*.deb
	@docker rmi "$(TAG)"

copy-conf:
	@cp -v tmux.conf /etc
	@cp -v tmux.pin  /etc/apt/preferences.d/tmux

install:
	@apt-get -y install ./"$(APP)_$(VERSION)"-1_$(ARCH).deb

uninstall:
	@apt-get purge "$(APP)"
	@rm -vf /etc/apt/preferences.d/tmux
	@rm -vi /etc/tmux.conf || true
