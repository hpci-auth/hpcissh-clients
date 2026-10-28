#!/bin/sh
set -eux

sudo apt-get -y remove podman || :

podman image rm ghcr.io/hpci-auth/hpcissh-almalinux10:latest || :
podman image rm ghcr.io/soum-takuya/hpcissh-almalinux10:develop || :

asciinema rec podman.cast -c "PS1='\[\e[32m\]hpci000000@ubuntu\[\e[0m\]:\[\e[34m\]~\[\e[0m\]\$ ' bash --norc"
