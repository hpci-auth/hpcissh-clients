# hpcissh-clients

OAuth-based ssh-client commands for HPCI

## Dependencies

- jq
- curl
- sshpass
- bash version 5 or later
- jwt-agent
- oidc-agent (optional)

## Quick Start

### Ubuntu 24.04 (works the same on WSL2)

TODO

### RHEL-based distribution (AlmaLinux, Rocky Linux, etc.)

TODO

### Homebrew on macOS

hpcissh can be installed using homebrew.

- Install Homebrew
  - <https://brew.sh/>
  - <https://docs.brew.sh/Installation>

Install hpcissh

```bash
brew tap hpci-auth/tap
brew install hpcissh
```

- (Optional) Install oidc-agent:
  - <https://indigo-dc.gitbook.io/oidc-agent/intro/macos>

## Installation

Choosing Your Installation Method:

- Option A: System-wide Installation (Requires root/sudo privileges)
- Option B: User-local Installation (No root access required, using ~/.local)

### Option A: System-wide Installation

```bash
make
sudo make install

(uninstall)
sudo make uninstall
```

### Option B: User-local Installation

```bash
make prefix=~/.local
make install prefix=~/.local

# Please ensure ~/.local/bin is in your PATH
# export PATH="$HOME/.local/bin:$PATH" >> ~/.bashrc

# (uninstall)
sudo make uninstall prefix=~/.local
```

- Overridable parameters: See `config.mk`

## Configuration

### Install HPCI SSH_CA

To update /etc/ssh/ssh_known_hosts (requires root privileges)

```
sudo hpcissh-append-ssh-ca --system --update
```

To update ~/.ssh/known_hosts per user

```
hpcissh-append-ssh-ca --user --update
```

### Configuration files for oidc-agent

For system-wide:

```
# (default)
PREFIX=/usr/local

sudo ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-main.conf /etc/oidc-agent/issuer.config.d/hpci-main
sudo ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-sub.conf  /etc/oidc-agent/issuer.config.d/hpci-sub
```

For each user:

```
PREFIX=/usr/local

mkdir -p ~/.config/oidc-agent/issuer.config.d/

ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-main.conf ~/.config/oidc-agent/issuer.config.d/hpci-main
ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-sub.conf  ~/.config/oidc-agent/issuer.config.d/hpci-sub
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

- jwt-agent:
  - Maximum Idle Period: 1 week
  - Maximum Lifetime (Expiration Period): 1 year
  - Agent forwarding is not supported.
- oidc-agent:
  - Maximum Lifetime (Expiration Period): 1 week
  - Agent forwarding is available.

#### jwt-agent

- (~/.hpcissh): set USE_JWT_AGENT=yes (default)
- Login to JWT server (Web UI): <https://elpis.hpci.nii.ac.jp>
  - or use sub system: <https://elpis-c.hpci.nii.ac.jp>
- Generate a JSON Web Token (JWT) and get the passphrase
- Run jwt-agent on your terminal
  - Copy from Web UI and Paste the command line, and input the passphrase

Example:

```
jwt-agent -s https://elpis.hpci.nii.ac.jp -l hpci00????
Passphrase:
Output JWT to /tmp/jwt_user_u501/token.jwt
```

To stop jwt-agent

```
jwt-agent --stop
```

#### oidc-agent

- (~/.hpcissh): set `USE_JWT_AGENT=no`
- `eval $(OIDC_AGENT_OPTS=--no-autoreauthenticate oidc-agent-service use)`
- `oidc-sshconf-hpci`
  - Enter encryption password
  - Confirm encryption password
  - Visit URL (OpenID provider)
  - Login
  - Enter the code

Example:

```
$ oidc-sshconf-hpci
Enter encryption password for account configuration 'hpci': 
Confirm encryption password: 
Generating account configuration ...
accepted

Using a browser on any device, visit:
https://metis.hpci.nii.ac.jp.test/auth/realms/HPCI/device

And enter the code: TLXE-QTHF
Alternatively you can use the following QR code to visit the above listed URL.

[QR code]
```

To delete encrypted configuration for HPCI:

```
$ oidc-gen -d hpci
Enter decryption password for account config 'hpci': 
Do you really want to delete this configuration? [No/yes/quit]: 
```

To stop oidc-agent:

```
eval $(oidc-agent-service stop)
```

### Step 2: Run hpcissh

Usage:

```
hpcissh <HOSTNAME> [command,args]...
hpcissh REMOTE_USER@<HOSTNAME> [command,args]...
```

### Other commands

- hpciscp
- hpcisftp
- hpcissh-config-show
- hpcissh-version
- hpci-get-userinfo

Examples:

```
$ hpci-parse-token
{
  "alg": "ES256",
  "typ": "JWT",
  "kid": "22kB6oAkPiHL4hrJEbc924yyvpNIWcnIajfqH2tQ4-c"
}
{
  "exp": 1771163157,
  "iat": 1771162557,
  "auth_time": 1771162555,
  "jti": "ofrtdg:30797276-abe9-2956-?????????????????",
  "iss": "https://metis.hpci.nii.ac.jp.test/auth/realms/HPCI",
  "aud": "hpci",
  "sub": "15fb569a-a483-4ac5-a49e-????????????",
  "typ": "Bearer",
  "azp": "hpci-pub",
  "sid": "50bd00d9-fc73-6749-6bcc-efaf76ad6173",
  "acr": "1",
  "scope": "scitokens hpci openid offline_access",
  "hpci.ver": "1.0",
  "hpci.id": "hpci00????",
  "ver": "scitokens:2.0",
  "nbf": 0
}
INFO: remaining time: 543 sec.
```

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
