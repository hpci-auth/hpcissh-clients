#!/bin/bash
set -euo pipefail

CHECK_LIST_COMMANDS=(
    hpcissh
    jwt-agent
    oidc-agent
    oidc-agent-service
    oidc-add
    oidc-gen
    oidc-token
)
CHECK_LIST_FILES=(
    /opt/hpcissh-clients/libexec/hpcissh-lib
    /opt/hpcissh-clients/share
    /opt/hpcissh-clients/share/hpcissh
    /opt/hpcissh-clients/share/hpcissh/known_hosts-HPCI-SSH_CA.txt
    /opt/hpcissh-clients/share/hpcissh/oidc-agent-v4_hpci-pubclients.config
    /opt/hpcissh-clients/share/hpcissh/oidc-agent_hpci-main.conf
    /opt/hpcissh-clients/share/hpcissh/oidc-agent_hpci-sub.conf
    /opt/oidc-agent/usr/lib/x86_64-linux-gnu/liboidc-agent.so.*
)

for cmd in "${CHECK_LIST_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "PASS: $cmd exists"
    else
        echo "FAIL: $cmd does not exist"
        exit 1
    fi
done

for file in "${CHECK_LIST_FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "PASS: $file exists"
    else
        echo "FAIL: $file does not exist"
        exit 1
    fi
done

"/opt/hpcissh-clients/bin/test-hpcissh"

echo "PASS: All tests passed."
