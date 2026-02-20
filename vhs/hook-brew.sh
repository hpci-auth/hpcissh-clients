#!/bin/bash
set -eu

REPLACE_TAP="${REPLACE_TAP_DIR}/${REPLACE_TAP_NAME}"
REPLACE_TAP_FULL="${REPLACE_TAP_DIR}/homebrew-${REPLACE_TAP_NAME}"

TARGET_TAP="hpci-auth/tap"
TARGET_TAP_DIR="${TARGET_TAP%/*}"
TARGET_TAP_NAME="${TARGET_TAP#*/}"
TARGET_TAP_FULL="${TARGET_TAP_DIR}/homebrew-${TARGET_TAP_NAME}"

slow_print() {
    sed -l -e "s|${REPLACE_TAP}|${TARGET_TAP}|g" \
        -e "s|${REPLACE_TAP_FULL}|${TARGET_TAP_FULL}|g" \
        -e "s|${REPLACE_TAP_DIR}|${TARGET_TAP_DIR}|g" \
        | while read -r line; do
        echo $line
        sleep 0.1
    done
}

brew() {
    case $1 in
        tap)
            TAP=$(echo "$2" | sed "s|${TARGET_TAP}|${REPLACE_TAP}|g")
            script -q /dev/null command brew tap "${TAP}" 2>&1 | slow_print
            ;;
        *)
            script -q /dev/null command brew "$@" 2>&1 | slow_print
            ;;
    esac
}
