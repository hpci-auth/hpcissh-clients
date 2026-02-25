#!/bin/sh
set -eux

# Available Fonts
fc-list :mono family | cut -d, -f1 | sort | uniq

agg --renderer fontdue \
    --cols 80 \
    --rows 20 \
    --theme monokai \
    --font-family "Ubuntu Mono" \
    podman.cast podman.gif
