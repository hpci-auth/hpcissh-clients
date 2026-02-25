#!/bin/sh
set -x

sed -i .orig \
    -e "s|soum-takuya/homebrew-tap-hpcidev|hpci-auth/homebrew-tap|g" \
    -e "s|soum-takuya/tap-hpcidev|hpci-auth/tap|g" \
    -e "s|soum-takuya|hpci000000|g" \
    -e "s|takuya|hpci000000|g" \
    macos.cast
