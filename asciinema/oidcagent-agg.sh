#!/bin/sh
set -eux

# For macOS

agg --renderer fontdue \
    --cols 80 \
    --rows 54 \
    --theme github-dark \
    --font-family "Menlo" \
    oidcagent.cast oidcagent.gif
