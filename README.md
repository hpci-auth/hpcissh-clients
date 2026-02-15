# hpcissh-clients

OAuth-based ssh-client commands for HPCI

## Dependencies

- jq
- curl
- sshpass
- bash version 5 or later
- jwt-agent
- oidc-agent (optional)

## Installation

```bash
make
sudo make install

(uninstall)
sudo make uninstall
```

### For macOS

hpcissh can be installed using homebrew.

```bash
brew tap hpci-auth/tap
brew install hpcissh
brew install jwt-agent
```

- Install oidc-agent:
  - <https://indigo-dc.gitbook.io/oidc-agent/intro/macos>

#### Manual installation for macOS

```bash
brew install bash jq sshpass
make prefix=~/.local bash_path=$(brew --prefix)/bin/bash
sudo make install prefix=~/.local

# Please ensure ~/.local/bin is in your PATH
# export PATH="$HOME/.local/bin:$PATH" >> ~/.bashrc

# (uninstall)
sudo make uninstall prefix=~/.local
```

NOTE: hpcissh does not work in bash version 3 (/usr/bin/bash on macOS).

## Configuration

### Install HPCI SSH_CA

To update /etc/ssh/ssh_known_hosts

```
hpcissh-append-ssh-ca --system --update
```

To update ~/.ssh/known_hosts per user

```
hpcissh-append-ssh-ca --user --update
```

### Configuration files for oidc-agent

```
# (default)
PREFIX=/usr/local

sudo ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-main.conf /etc/oidc-agent/issuer.config.d/hpci-main
sudo ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-sub.conf  /etc/oidc-agent/issuer.config.d/hpci-sub
```

Homebrew (macOS):

```
# (Please install oidc-agent in advance)

HOMEBREW_PREFIX=$(brew --prefix)

ln -sf ${HOMEBREW_PREFIX}/opt/hpcissh/share/hpcissh/oidc-agent_hpci-main.conf ${HOMEBREW_PREFIX}/etc/oidc-agent/issuer.config.d/hpci-main
ln -sf ${HOMEBREW_PREFIX}/opt/hpcissh/share/hpcissh/oidc-agent_hpci-sub.conf  ${HOMEBREW_PREFIX}/etc/oidc-agent/issuer.config.d/hpci-sub
```

### Customize

Please refer to "Configurable parameters" for how to change the settings.

## Usage

### Step 1: Preparation (get and update Access Token)

Please choose either jwt-agent or oidc-agent to proceed.

#### jwt-agent

- (~/.hpcissh): set USE_JWT_AGENT=yes (default)
- Login to JWT server: <https://elpis.hpci.nii.ac.jp>
  - or use sub system: <https://elpis-c.hpci.nii.ac.jp>
- Generate a JSON Web Token (JWT) and get the passphrase
- Run jwt (Copy and Paste the command line, and input the passphrase)

Example:

```
jwt-agent -s https://elpis.hpci.nii.ac.jp -l hpci00????
Passphrase:
Output JWT to /tmp/jwt_user_u501/token.jwt

# (To stop)
jwt-agent --stop
```

#### oidc-agent

- (~/.hpcissh): set USE_JWT_AGENT=no

TODO

### Step 2: Run hpcissh

Example:

```
hpcissh <HOSTNAME> [command,args]...
hpcissh REMOTE_USER@<HOSTNAME> [command,args]...
```

### Other commands

- hpciscp
- hpcisftp
- hpcissh-config-show
- hpcissh-version
- hpci-parse-token
- hpci-get-userinfo

## Configurable parameters

Run `hpcissh-config-show` command to print the current parameters.

To customize parameters, specify the values in `~/.hpcissh` or environment variables.

The following items can be configured:

- USE_JWT_AGENT
  - If yes, jwt-agent is used in preference to oidc-agent
  - type: yes or no
  - default: yes
- HPCISSH_DEBUG_X
  - run with `set -x`
  - type: yes or no
  - default: no
- HPCISSH_DEBUG
  - debug mode
  - type: yes or no
  - default: no
- HPCISSH_QUIET
  - shut up WARNING
  - type: yes or no
  - default: no
- OIDC_AT_LEAST_VALID_TIME
  - remaining valid time before using access token
  - for oidc-agent
  - type: integer (second)
  - default: 180
- OIDC_AGENT_FORWARD
  - enable forwarding oidc-agent connection
  - for oidc-agent + hpcissh
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
- OIDC_AGENT_USE_PW_ENV
  - suppress oidc-prompt (GUI popup)
  - for oidc-agent
  - type: yes or no
  - default: yes
- OIDC_USERINFO_ENDPOINT_PATH
  - path of userinfo endpoint
  - default: (See script/hpcissh-lib)
- OIDC_USERINFO_ENDPOINT
  - OpenID userinfo endpoint (URL)
  - type: string
  - default: auto (use "iss" + OIDC_USERINFO_ENDPOINT_PATH)
- OIDC_USERINFO_EXPIRE
  - lifetime of cached userinfo file (~/.hpcissh.local_accounts)
  - type: integer (second)
  - default: 1800
- HPCISSH_PORT
  - port nunmber of hpcissh server
  - type: integer
  - default: 2222
- HPCISSH_TOKEN_INPUT
  - sshpass or SSH_ASKPASS
  - type: string
  - default: sshpass
- AUTO_LOGIN_NAME
  - Login name is automatically added
  - type: yes or no
  - default: yes

## For developer

### Testing

```bash
make all install test clean uninstall prefix=$(pwd)/LOCAL

### (macOS)
make all install test clean uninstall prefix=$(pwd)/LOCAL bash_path=$(brew --prefix)/bin/bash

# Check that all files have been removed.
find ./LOCAL

rm -rf ./LOCAL
```
