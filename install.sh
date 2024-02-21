#!/bin/sh

set -x
set -eu

PREFIX="${1:-/usr/local}"

cd ./script
install -v -p -D -t ${PREFIX}/bin *

chmod 644 ${PREFIX}/bin/hpcissh-lib
