# Release note for hpcissh-clients

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
