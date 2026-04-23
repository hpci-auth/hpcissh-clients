# Release note for hpcissh-clients

## version 1.12.0 (2026-04-??)

- New feature
  - container image for Podman
  - support macOS platform using Homebrew
- Update feature
  - automatically use HPCI SSH CA (no need to edit the known_hosts file anymore)
  - By using hpci-oidc-agent-service, HPCI configurations for oidc-agent is added automatically
  - improve shell detection logic for csh/tcsh users in hpci-oidc-agent-service
  - oidc-sshconf-hpci: Automatically re-authenticates upon expiration
  - revise the error messages and suggested re-login commands for expired refresh token to ensure re-authentication works across all supported environments
  - fallback to oidc-agent automatically when the jwt-agent token is expired
  - suppress oidc-prompt (GUI popup) for oidc-agent
  - change installer (make && make install)
- New command
  - hpci-oidc-agent-service
  - hpcissh-config-show
  - hpcissh-append-ssh-ca
- New configuration directive
  - HPCISSH_AUTO_KNOWN_HOSTS (default: yes)
  - HPCISSH_AUTO_LOGIN_NAME (default: yes)
  - HPCISSH_SHELL_TYPE (default: auto)
  - OIDC_AGENT_USE_PW_ENV (default: yes)
  - OIDC_AGENT_OPTS

## version 1.11 (2024-10-30)

- Update feature
  - auto OIDC_USERINFO_ENDPOINT
- New configuration directive
  - OIDC_USERINFO_ENDPOINT_PATH
  - HPCISSH_QUIET=yes/no(default)

## version 1.10 (2024-07-30)

- Update feature
  - ignore validity date (iat, exp) on the client side
  - compatible with jq version 1.5 and earlier 

## version 1.9 (2024-02-22)

- Update feature
  - OIDC_USERINFO_EXPIRE: change default value (1800 sec.)
  - report error message from curl command
  - "WARNING: Failed to find your remote username" is no longer reported

## version 1.8 (2023-12-19)

- Update feature
  - report "WARNING: Failed to find your remote username" when the ssh server name is unknown

## version 1.7

- New feature
  - support jwt-agent
  - report expired token
- Update feature
  - jwt-cli (jwt command) is not required from this version
- New command
  - hpci-parse-token
  - hpci-token (equivalent to oidc-token-hpci)
- New configuration directive
  - USE_JWT_AGENT=yes(default)/no
  - HPCISSH_TOKEN_INPUT=sshpass(default)/SSH_ASKPASS
  - HPCISSH_DEBUG_X=yes/no(default)

## version 1.6

- Bug fix
  - fix incorrect exit-code from remote

## version 1.5

- Bug fix
  - test-hpcissh: fix "HPCISSH_DEBUG: unbound variable"

## version 1.4

- initial version
