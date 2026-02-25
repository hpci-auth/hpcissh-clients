#!/bin/sh
set -eux

eval `hpci-oidc-agent-service use`
oidc-gen -d hpci || :
eval `hpci-oidc-agent-service stop` || :

rm -f ~/.config/oidc-agent/issuer.config.d/hpci-main
rm -f ~/.config/oidc-agent/issuer.config.d/hpci-sub
if [ -f ~/.config/oidc-agent/pubclients.config ]; then
    rm -i ~/.config/oidc-agent/pubclients.config
fi

asciinema rec oidcagent.cast -c "PS1='\[\e[32m\]hpci000000@bash\[\e[0m\]:\[\e[34m\]~\[\e[0m\]\$ ' bash --norc -i"
