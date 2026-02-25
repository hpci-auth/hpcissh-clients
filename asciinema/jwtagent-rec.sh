#!/bin/sh
set -eux

asciinema rec jwtagent.cast -c "PROMPT_EOL_MARK= PROMPT='hpci000000@zsh ~ %# ' zsh -f -i"
