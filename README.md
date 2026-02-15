# hpcissh-clients

OAuth-based SSH client toolset for HPCI.

## Dependencies

- `jq`
- `curl`
- `sshpass`
- `bash` (version 5 or later)
- `jwt-agent`
- `oidc-agent` (optional)

## Quick Start

### Ubuntu 24.04 (including WSL2)

*(Detailed instructions coming soon)*

### RHEL-based distributions (AlmaLinux, Rocky Linux, etc.)

*(Detailed instructions coming soon)*

### macOS (via Homebrew)

`hpcissh` can be installed directly using Homebrew.

1.  **Install Homebrew** (if not already installed):
    - <https://brew.sh/>
2.  **Install hpcissh**:
    ```bash
    brew tap hpci-auth/tap
    brew install hpcissh
    ```
3.  **(Optional) Install oidc-agent**:
    - <https://indigo-dc.gitbook.io/oidc-agent/intro/macos>

## Installation

### Option A: System-wide Installation (Requires root/sudo privileges)

```bash
make
sudo make install
```

To uninstall:
```bash
sudo make uninstall
```

### Option B: User-local Installation (Installs to `~/.local`)

```bash
make prefix=~/.local
make install prefix=~/.local
```

Ensure `~/.local/bin` is in your `PATH`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

To uninstall:
```bash
make uninstall prefix=~/.local
```

- **Note**: For overridable parameters, see `config.mk`.

## Configuration

### Installing the HPCI SSH CA

Update the system-wide `known_hosts` (requires root privileges):
```bash
sudo hpcissh-append-ssh-ca --system --update
```

Update the `known_hosts` for the current user:
```bash
hpcissh-append-ssh-ca --user --update
```

### Configuring oidc-agent Issuer Profiles

#### System-wide:

```bash
PREFIX=/usr/local # Adjust if a different prefix was used
sudo ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-main.conf /etc/oidc-agent/issuer.config.d/hpci-main
sudo ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-sub.conf  /etc/oidc-agent/issuer.config.d/hpci-sub
```

#### Per-user:

```bash
PREFIX=/usr/local
mkdir -p ~/.config/oidc-agent/issuer.config.d/
ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-main.conf ~/.config/oidc-agent/issuer.config.d/hpci-main
ln -sf ${PREFIX}/share/hpcissh/oidc-agent_hpci-sub.conf  ~/.config/oidc-agent/issuer.config.d/hpci-sub
```

#### macOS (Homebrew):

```bash
# Ensure oidc-agent is installed
HOMEBREW_PREFIX=$(brew --prefix)
ln -sf ${HOMEBREW_PREFIX}/opt/hpcissh/share/hpcissh/oidc-agent_hpci-main.conf ${HOMEBREW_PREFIX}/etc/oidc-agent/issuer.config.d/hpci-main
ln -sf ${HOMEBREW_PREFIX}/opt/hpcissh/share/hpcissh/oidc-agent_hpci-sub.conf  ${HOMEBREW_PREFIX}/etc/oidc-agent/issuer.config.d/hpci-sub
```

## Usage

### Step 1: Obtain an Access Token

Choose between `jwt-agent` or `oidc-agent`.

| Feature | `jwt-agent` | `oidc-agent` |
| :--- | :--- | :--- |
| **Max Idle Period** | 1 week | 1 week |
| **Max Lifetime** | 1 year | 1 week |
| **Agent Forwarding** | No | Yes |

#### Using jwt-agent

1.  Ensure `USE_JWT_AGENT=yes` in `~/.hpcissh` (this is the default).
2.  Login to the HPCI JWT server: <https://elpis.hpci.nii.ac.jp> (or sub-system: <https://elpis-c.hpci.nii.ac.jp>).
3.  Generate a JSON Web Token (JWT) and obtain the passphrase.
4.  Run `jwt-agent` in your terminal (copy and paste the provided command), and enter the passphrase.

To stop the agent: `jwt-agent --stop`

#### Using oidc-agent

1.  Set `USE_JWT_AGENT=no` in `~/.hpcissh`.
2.  Initialize the agent: `eval $(OIDC_AGENT_OPTS=--no-autoreauthenticate oidc-agent-service use)`
3.  Configure the HPCI account: `oidc-sshconf-hpci`
    - Follow the prompts to authenticate via your browser.

To stop the agent: `eval $(oidc-agent-service stop)`

### Step 2: Connect via hpcissh

```bash
# Automatically resolve and append the remote login name
hpcissh <HOSTNAME> [command,args]...

# To specify the remote login name
hpcissh REMOTE_USER@<HOSTNAME> [command,args]...
```

### Other Commands

- `hpciscp`: Secure copy
- `hpcisftp`: Secure FTP
- `hpcissh-config-show`: Display current configurations
- `hpcissh-version`: Show version info
- `hpci-get-userinfo`: Retrieve OIDC user information
- `hpci-parse-token`: Parse and display JWT claims

## Configurable Parameters

Use the `hpcissh-config-show` command to view the current parameters. To customize them, specify values in `~/.hpcissh` or use environment variables.

The following items can be configured:

- **`USE_JWT_AGENT`**
  - Use `jwt-agent` instead of `oidc-agent`.
  - Type: yes/no, Default: `yes`
- **`HPCISSH_DEBUG_X`**
  - Run scripts with `set -x`.
  - Type: yes/no, Default: `no`
- **`HPCISSH_DEBUG`**
  - Enable debug mode.
  - Type: yes/no, Default: `no`
- **`HPCISSH_QUIET`**
  - Suppress warning messages.
  - Type: yes/no, Default: `no`
- **`OIDC_AT_LEAST_VALID_TIME`**
  - Minimum remaining validity (in seconds) required for an access token. (For `oidc-agent`)
  - Type: integer, Default: `180`
- **`OIDC_AGENT_FORWARD`**
  - Enable forwarding of the `oidc-agent` connection.
  - Type: yes/no, Default: `yes`
- **`OIDC_AGENT_CONF_NAME`**
  - The account configuration name used for `oidc-agent`.
  - Type: string, Default: `hpci`
- **`OIDC_ISSUER`**
  - The OpenID Connect issuer URL.
  - Type: string, Default: (See `script/hpcissh-lib`)
- **`OIDC_AGENT_USE_PW_ENV`**
  - Suppress the `oidc-prompt` (GUI popup) by using environment variables for passwords.
  - Type: yes/no, Default: `yes`
- **`OIDC_USERINFO_ENDPOINT_PATH`**
  - The path to the userinfo endpoint.
  - Default: (See `script/hpcissh-lib`)
- **`OIDC_USERINFO_ENDPOINT`**
  - The full URL for the OpenID userinfo endpoint.
  - Type: string, Default: `auto` (constructed from `iss` + `OIDC_USERINFO_ENDPOINT_PATH`)
- **`OIDC_USERINFO_EXPIRE`**
  - Lifetime (in seconds) of the cached user information file (`~/.hpcissh.local_accounts`).
  - Type: integer, Default: `1800`
- **`HPCISSH_PORT`**
  - The destination SSH port for `hpcissh` servers.
  - Type: integer, Default: `2222`
- **`HPCISSH_TOKEN_INPUT`**
  - Method for token input: `sshpass` or `SSH_ASKPASS`.
  - Type: string, Default: `sshpass`
- **`AUTO_LOGIN_NAME`**
  - Automatically resolve and append the remote login name.
  - Type: yes/no, Default: `yes`

## For Developers

### Testing

```bash
make all install test clean uninstall prefix=$(pwd)/LOCAL
```

On macOS:
```bash
make all install test clean uninstall prefix=$(pwd)/LOCAL bash_path=$(brew --prefix)/bin/bash
find ./LOCAL
rm -rf ./LOCAL
```
