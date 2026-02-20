# hpcissh-clients

OAuth-based SSH client toolset for HPCI.

## Dependencies

- `jq`
- `curl`
- `sshpass`
- `bash` (version 5 or later)
- `jwt-agent`
- `oidc-agent` (optional)

## Installation

### Podman

(Detailed instructions coming soon.)

### Ubuntu 24.04 (including WSL2)

(Detailed instructions coming soon.)

- **Note**: `oidc-agent` is version 4 on this platform.

### RHEL-based distributions (AlmaLinux, Rocky Linux, etc.)

(Detailed instructions coming soon.)

### macOS (via Homebrew)

`hpcissh` can be installed directly using Homebrew.

1. **Install Homebrew**: <https://brew.sh/>
2. **Install hpcissh** (jwt-agent is also installed):

    ```bash
    brew tap hpci-auth/tap
    brew install hpcissh
    ```

3. **(Optional) Install oidc-agent**:
    - <https://indigo-dc.gitbook.io/oidc-agent/intro/macos>

    ```bash
    brew tap indigo-dc/oidc-agent
    brew install oidc-agent
    ```

![demo-macos](./vhs/macos.gif)

#### Upgrading or Uninstalling (Homebrew)

```bash
# To upgrade
brew update
brew upgrade hpcissh

# To uninstall
brew uninstall hpcissh
brew untap hpci-auth/tap
brew uninstall oidc-agent
brew untap indigo-dc/oidc-agent
```

### Manual Installation

**Prerequisites**: Please ensure all [Dependencies](#dependencies)
(e.g., `jwt-agent`, `sshpass`, etc.) are installed on your system before
proceeding. Detailed installation instructions for each dependency are omitted
here.

#### System-wide Installation (Requires root/sudo privileges)

```bash
make
sudo make install
```

#### Upgrading or Uninstalling (System-wide)

```bash
# To upgrade (after updating the source code)
make
sudo make install

# To uninstall
sudo make uninstall
```

#### User-local Installation (Installs to `~/.local`)

```bash
make prefix=~/.local
make install prefix=~/.local
```

#### Upgrading or Uninstalling (User-local)

```bash
# To upgrade (after updating the source code)
make prefix=~/.local
make install prefix=~/.local

# To uninstall
make uninstall prefix=~/.local
```

Ensure `~/.local/bin` is in your `PATH`. We recommend adding the following line
to your `~/.bashrc` (for Bash) or `~/.zshrc` (for Zsh):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

To apply this change immediately in your current terminal session, run:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

- **Note**: For overridable parameters, see `config.mk`.

---

## Configuration

### Installing the HPCI SSH CA (Public Key)

By default, this procedure is **not required** because `hpcissh` automatically
uses the HPCI SSH CA via the `KnownHostsCommand` SSH option (controlled by the
`HPCISSH_AUTO_KNOWN_HOSTS` parameter).

However, if you set `HPCISSH_AUTO_KNOWN_HOSTS=no` or wish to perform a manual
installation, execute the following:

Update the system-wide `/etc/ssh/ssh_known_hosts` (requires root privileges):

```bash
sudo hpcissh-append-ssh-ca --system --update
```

Update the `~/.ssh/known_hosts` for the current user:

```bash
hpcissh-append-ssh-ca --user --update
```

### Configuring Issuer Profiles for oidc-agent

The following files are managed automatically by the `oidc-sshconf-hpci` command.

- **For oidc-agent v4**: `~/.config/oidc-agent/pubclients.config`
- **For oidc-agent v5**: `~/.config/oidc-agent/issuer.config.d/hpci-main`
  and `hpci-sub`

---

## Usage

### Step 1: Obtain an Access Token

Choose between `jwt-agent` and `oidc-agent`.

| Feature / HPCI Parameter | `jwt-agent` | `oidc-agent` |
| :--- | :--- | :--- |
| **Max Idle Period** | 1 week | 1 week |
| **Max Lifetime** | 1 year | 1 week |
| **Access Token Lifetime** | 600 sec. | 600 sec. |
| **Agent Forwarding** | No | Yes |

#### Step 1-1: Using jwt-agent

1. Ensure `USE_JWT_AGENT=yes` (default) in `~/.hpcissh`.
2. Log in to the HPCI JWT server: <https://elpis.hpci.nii.ac.jp>
   (or <https://elpis-c.hpci.nii.ac.jp>).
3. Generate a JWT and obtain the passphrase.
4. Run `jwt-agent` in your terminal and enter the passphrase.

To stop the agent: `jwt-agent --stop`

#### Step 1-2: Using oidc-agent

1. Set `USE_JWT_AGENT=no` in `~/.hpcissh`.
2. (Optional) To use the sub-system: Set
   `OIDC_ISSUER="https://metis-c.hpci.nii.ac.jp/auth/realms/HPCI"` in
   `~/.hpcissh`.
3. Initialize the agent: `eval $(oidc-agent-service use)`
4. Generate HPCI account configurations: `oidc-sshconf-hpci`
    - Follow the prompts to authenticate via your browser.

To use `oidc-agent` in another terminal: `eval $(oidc-agent-service use)`
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
- `hpcisftp`: Secure file transfer (SFTP)
- `hpcissh-config-show`: Display current configurations
- `hpcissh-version`: Show version info
- `hpci-get-userinfo`: Retrieve OIDC user information
- `hpci-parse-token`: Parse and display JWT claims
- `hpci-token`: Display JWT

---

## Configurable Parameters

Use `hpcissh-config-show` to view current settings. Customize them via
environment variables or `~/.hpcissh`.

The following items can be configured:

- **`USE_JWT_AGENT`**
  - Use `jwt-agent` instead of `oidc-agent`. (yes/no, default: `yes`)
- **`HPCISSH_DEBUG_X`**
  - Run scripts with `set -x`. (yes/no, default: `no`)
- **`HPCISSH_DEBUG`**
  - Enable debug mode. (yes/no, default: `no`)
- **`HPCISSH_QUIET`**
  - Suppress warning messages. (yes/no, default: `no`)
- **`OIDC_AT_LEAST_VALID_TIME`**
  - Minimum remaining validity (in seconds) required for an access token.
    (For `oidc-agent`)
- **`OIDC_AGENT_OPTS`**
  - Options for `oidc-agent`. (default: `--no-autoreauthenticate`)
- **`OIDC_AGENT_FORWARD`**
  - Enable forwarding of the `oidc-agent` connection.
    (yes/no, default: `yes`)
- **`OIDC_AGENT_CONF_NAME`**
  - The account configuration name used for `oidc-agent`.
    (default: `hpci`)
- **`OIDC_ISSUER`**
  - The OpenID Connect issuer URL. (default: See `script/hpcissh-lib`)
- **`OIDC_AGENT_USE_PW_ENV`**
  - Use `--pw-env` for `oidc-gen` and `oidc-add`.
    (yes/no, default: `yes`)
- **`OIDC_USERINFO_ENDPOINT_PATH`**
  - Path to the userinfo endpoint. (default: See `script/hpcissh-lib`)
- **`OIDC_USERINFO_ENDPOINT`**
  - Full URL for the userinfo endpoint. (default: `auto`)
- **`OIDC_USERINFO_EXPIRE`**
  - Lifetime (in seconds) of cached user info. (default: `1800`)
- **`HPCISSH_PORT`**
  - Destination SSH port. (default: `2222`)
- **`HPCISSH_TOKEN_INPUT`**
  - Method for token input: `sshpass` or `SSH_ASKPASS`.
    (default: `sshpass`)
- **`HPCISSH_AUTO_LOGIN_NAME`**
  - Automatically use remote login name. (yes/no, default: `yes`)
- **`HPCISSH_AUTO_KNOWN_HOSTS`**
  - Automatically use HPCI SSH CA. (yes/no, default: `yes`)

---

## For Developers

### Offline testing

```bash
make all install test clean uninstall prefix=$(pwd)/LOCAL
find ./LOCAL
rm -rf ./LOCAL
```

On macOS:

```bash
make all install test clean uninstall prefix=$(pwd)/LOCAL bash_path=$(brew --prefix)/bin/bash
find ./LOCAL
rm -rf ./LOCAL
```

### Online testing

```bash
# (Run jwt-agent)
# (Run oidc-agent)
# (Install hpcissh to $(pwd)/LOCAL)

./run-tests.sh --prefix ./LOCAL ??????.ac.jp
./run-tests.sh --prefix ./LOCAL ??????.ac.jp --run
```
