#!/bin/bash
set -eu
set -x

# Set tap name for developer instead of hpci-auth/tap
TAP="$1"

REPLACE_TAP_DIR="${TAP%/*}"
REPLACE_TAP_NAME="${TAP#*/}"

# check
[ -z "${REPLACE_TAP_DIR}" ] && exit 1
[ -z " ${REPLACE_TAP_NAME}" ] && exit 2


brew uninstall hpcissh || :
brew uninstall oidc-agent || :
brew untap "$TAP" || :
brew untap indigo-dc/oidc-agent || :

export REPLACE_TAP_DIR
export REPLACE_TAP_NAME
vhs < macos.tape
