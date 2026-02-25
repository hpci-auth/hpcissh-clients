#!/bin/sh
set -eux

# For macOS

agg --renderer fontdue \
    --cols 80 \
    --rows 20 \
    --theme github-dark \
    --font-family "Menlo" \
    jwtagent.cast jwtagent.gif
