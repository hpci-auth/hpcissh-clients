#!/bin/sh
set -x

sed -i .orig \
    -e "s|hpci001971|hpci000000|g" \
    -e "s|takuya|hpci000000|g" \
    -e 's|\\u001b\[27m1\\u001b\[27m9\\u001b\[27m7\\u001b\[27m1|\\u001b\[27m0\\u001b\[27m0\\u001b\[27m0\\u001b\[27m0|g' \
    jwtagent.cast
