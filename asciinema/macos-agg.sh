#!/bin/sh
set -eux

agg --renderer fontdue \
    --cols 80 \
    --rows 20 \
    --theme dracula \
    --font-family "Menlo" \
    macos.cast macos.gif
