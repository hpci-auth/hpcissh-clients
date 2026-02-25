#!/bin/sh
set -eux

#asciinema rec jwtagent.cast -c "PS1='\[\e[32m\]hpci000000@hpcissh\[\e[0m\]:\[\e[34m\]~\[\e[0m\]\$ ' bash --norc"

asciinema rec jwtagent.cast -c "PROMPT_EOL_MARK= PROMPT='hpci000000@zsh ~ %# ' zsh -f -i"
#asciinema rec jwtagent.cast -c "PS1='\[\e[32m\]hpci000000@bash\[\e[0m\] ~ % ' bash --norc"
