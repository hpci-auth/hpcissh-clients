# hpcissh-clients

OAuth-based ssh-client commmands for HPCI

## Parameters

for configuration file (~/.hpcissh) or environment variable.

- OIDC_USERINFO_EXPIRE
  - lifetime of cached userinfo file (~/.hpcissh.local_accounts)
  - type: integer (second)
  - default: 1800
- USE_JWT_AGENT
  - If yes, jwt-agent is used in preference to oidc-agent
  - type: yes or no
  - default: yes
- HPCISSH_QUIET
  - shut up WARNING
  - type: yes or no
  - default: no
- HPCISSH_DEBUG
  - debug mode
  - type: yes or no
  - default: no
- HPCISSH_DEBUG_X
  - run with `set -x`
  - type: yes or no
  - default: no
- OIDC_AT_LEAST_VALID_TIME
  - remaining valid time before using access token
  - for oidc-agent
  - type: integer (second)
  - default: 180
- OIDC_AGENT_FORWARD
  - enable forwarding oidc-agent connection
  - for oidc-agent
  - type: yes or no
  - default: yes
- OIDC_AGENT_CONF_NAME
  - specify the same as the <conf name> specified for oidc-sshconf
  - for oidc-agent
  - type: string
  - default: hpci
- OIDC_ISSUER
  - issuer URL (OpenID provider)
  - for oidc-agent
  - type: string
  - default: (See script/hpcissh-lib)
- OIDC_USERINFO_ENDPOINT
  - OpenID userinfo endpoint (URL)
  - type: string
  - default: auto (use "iss" + OIDC_USERINFO_ENDPOINT_PATH)
- OIDC_USERINFO_ENDPOINT_PATH
  - path of userinfo endpoint
  - default: (See script/hpcissh-lib)
- HPCISSH_PORT
  - port nunmber of hpcissh server
  - type: integer
  - default: 2222
- HPCISSH_TOKEN_INPUT
  - sshpass or SSH_ASKPASS
  - type: string
  - default: sshpass
