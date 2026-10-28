#!/bin/sh
set -eux

brew uninstall hpcissh jwt-agent || :
brew uninstall oidc-agent || :
brew untap soum-takuya/homebrew-tap-hpcidev || :
brew untap hpci-auth/homebrew-tap || :
brew untap indigo-dc/oidc-agent || :

asciinema rec macos.cast -c "PS1='hpci000000@macOS ~ % ' bash --norc"
