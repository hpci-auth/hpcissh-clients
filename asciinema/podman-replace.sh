#!/bin/sh
set -x

sed -i.orig \
    -e "s|soum-takuya/|hpci-auth/|g" \
    -e "s|:develop|:latest|g" \
    -e "s|takuya|hpci000000|g" \
    podman.cast
