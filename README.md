# hpcissh-clients

OAuth-based SSH client toolset for HPCI.

## Dependencies

The following tools are required for the scripts to function:

- `ssh` (OpenSSH): Remote login tools with the SSH protocol.
- `sshpass`: Non-interactive SSH password provider.
- `jq`: JSON processor.
- `curl`: Tool for transferring data with URLs.
- `bash` (Version 5 or later): For executing shell-scripts.
- `ps` (procps-ng,procps): Display current processes.
- `jwt-agent`: For managing JWT tokens.
  - <https://github.com/oss-tsukuba/jwt-agent>
- `oidc-agent` (optional): For managing JWT tokens and agent forwarding.
  - <https://github.com/indigo-dc/oidc-agent>

## Installation

### Case 1: Using Container for Podman (or Docker)

The easiest way to get started without manually installing all dependencies.

**Note**: Podman operates without requiring root privileges
(rootless). In contrast, Docker typically runs with elevated
privileges. Please ensure you fully understand the security
implications of these permissions before using Docker.

#### Demo: Deploying with Podman

![demo-podman](./asciinema/podman.gif)

#### OS-specific Podman Setup

- **WSL2 (Windows 11)**:
  - There are two ways to install Podman.
    - WSL2 is required for both methods.
      - See: <https://learn.microsoft.com/en-us/windows/wsl/install>
  - Option A: Install Podman within Ubuntu on WSL2
    - Run `sudo apt-get update && sudo apt-get -y install podman`
  - Option B: Download Podman Installer (Podman CLI for Windows) from <https://podman.io/>
    - Run the installer and follow the on-screen instructions.
    - (In Powershell) Run `podman machine init` and `podman machine start`
- **macOS**:
  - There are two ways to install Podman.
  - Option A: Install Podman via Homebrew
    1. Install Homebrew: <https://brew.sh/>
    2. Run `brew install podman`
    3. Run `podman machine init && podman machine start`
  - Option B: Download Podman Installer (Podman CLI for macOS) from <https://podman.io/>
    - Run the installer and follow the on-screen instructions.
    - Run `podman machine init && podman machine start`
- **Linux Distributions**: Install Podman via the package manager
  - Debian / Ubuntu:
    - Run `sudo apt-get update && sudo apt-get -y install podman`
  - RHEL / RHEL-based (AlmaLinux / Rocky Linux / etc.):
    - Run `sudo dnf -y install podman`
    - Run `sudo loginctl enable-linger <USERNAME_FOR_PODMAN>`
      - Run this for all users who will be using Podman.

For more details, refer to <https://podman.io/docs/installation>.

#### Common Procedures for Podman (or Docker)

1. **Start the Container**:
   Run the following command (it mounts your host's `$HOME` to `/HOST_HOMEDIR`):

    ```bash
    # Using Podman (recommended):
    podman run --userns=keep-id \
      --rm -it --init --hostname hpcissh --name hpcissh \
      --mount type=bind,src=${HOME},dst=/HOST_HOMEDIR \
      -e USER_UID=$(id -u) \
      -e USER_GID=$(id -g) \
      -e USER_NAME=$(id -un) \
      ghcr.io/hpci-auth/hpcissh-almalinux10:latest
    ```

    ```bash
    # If using Docker:
    docker run \
      --rm -it --init --hostname hpcissh --name hpcissh \
      --mount type=bind,src=${HOME},dst=/HOST_HOMEDIR \
      -e USER_UID=$(id -u) \
      -e USER_GID=$(id -g) \
      -e USER_NAME=$(id -un) \
      ghcr.io/hpci-auth/hpcissh-almalinux10:latest
    ```

    ```powershell
    # If using Podman in Windows Powershell:
    PS C:\Users\USERNAME> podman run --userns=keep-id `
        --rm -it --init --hostname hpcissh --name hpcissh `
        --mount type=bind,src=${HOME},dst=/HOST_HOMEDIR `
        -e USER_UID=1000 `
        -e USER_GID=1000 `
        -e USER_NAME=USERNAME `
        ghcr.io/hpci-auth/hpcissh-almalinux10:latest
    ```

2. Follow the steps in [Using hpcissh](#using-hpcissh) inside the container.
3. Type `exit` to quit. The container is automatically removed.
    - **Warning**: Any files stored strictly within the container are volatile and will be deleted automatically.
      Always copy important data to `~/HOST_HOMEDIR/` for permanent storage.

#### Updating the Container image before starting the container

```bash
# Using Podman
podman pull ghcr.io/hpci-auth/hpcissh-almalinux10:latest

# Using Docker
docker pull ghcr.io/hpci-auth/hpcissh-almalinux10:latest
```

#### Building the Container image Locally

```bash
cd docker
podman build -f Dockerfile-almalinux -t hpcissh-almalinux10:localdev \
  --build-arg ALMA_VERSION=10 \
  --build-arg OIDC_AGENT_VERSION=4.5.2 \
  --build-arg JWT_AGENT_VERSION=1.1.1 \
  ../
```

---

### Case 2: macOS Native package via Homebrew

#### Demo: Deploying on macOS

![demo-macos](./asciinema/macos.gif)

#### Installing hpcissh for macOS

1. **Install Homebrew**: <https://brew.sh/>
2. **Install hpcissh**:

    ```bash
    brew tap hpci-auth/tap
    brew install hpcissh
    ```

3. **(Optional) Install oidc-agent**:
    - Refer to: <https://indigo-dc.gitbook.io/oidc-agent/intro/macos>

    ```bash
    brew tap indigo-dc/oidc-agent
    brew install oidc-agent
    ```

#### Upgrading or Uninstalling

```bash
# To upgrade
brew update && brew upgrade hpcissh

# To uninstall
brew uninstall hpcissh && brew untap hpci-auth/tap
brew uninstall oidc-agent && brew untap indigo-dc/oidc-agent
```

---

### Case 3: Manual Setup

**Prerequisites**: Ensure all [Dependencies](#dependencies) are installed.

#### Manual Setup: System-wide Installation

(Requires sudo)

```bash
make
sudo make install
```

#### Manual Setup: User-local Installation

(e.g., to `~/.local`)

```bash
make build install prefix=$HOME/.local
```

For macOS

```bash
make build install prefix=$HOME/.local bash_path=$(brew --prefix)/bin/bash
```

Note: `/bin/bash` is bash version 3

**Apply PATH changes**: Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

To apply immediately, run `export PATH="$HOME/.local/bin:$PATH"`

---

## Configurations

**No changes needed** for default settings.

### SSH CA (Public Key) for HPCI

`hpcissh` command automatically uses the public key of the SSH CA for HPCI to verify SSH servers. Manual setup is **NOT required** unless `HPCISSH_AUTO_KNOWN_HOSTS=no` is set.

To manually update:

```bash
# System-wide
sudo hpcissh-append-ssh-ca --system --update
# User-specific
hpcissh-append-ssh-ca --user --update
```

### Issuer Profiles for oidc-agent

The following files are managed automatically by `oidc-sshconf-hpci`:

- **For oidc-agent v4**: `~/.config/oidc-agent/pubclients.config`
- **For oidc-agent v5**: `~/.config/oidc-agent/issuer.config.d/hpci-main` and `hpci-sub`

---

## Using hpcissh

### Step 1: Obtain an Access Token

Choose the agent that fits your workflow. **`jwt-agent` is recommended for most users.**

| Feature / Parameter | `jwt-agent` (Default) | `oidc-agent` |
| :--- | :--- | :--- |
| **Max Idle Period** | 1 week | 1 week |
| **Max Lifetime** | 1 year | 1 week |
| **Access Token Lifetime** | 600 sec. | 600 sec. |
| **Agent Forwarding** | No | Yes |
| **For hpcissh login** | Yes | Yes |
| **For HPCI Shared Storage** | Yes | Yes |

#### Option A: Using `jwt-agent`

1. Log in to the HPCI JWT server: [elpis (main-system)](https://elpis.hpci.nii.ac.jp) or [elpis-c (sub-system)](https://elpis-c.hpci.nii.ac.jp).
2. Generate a JWT and copy the provided **passphrase**.
3. Run `jwt-agent` and enter the **passphrase**.
4. (Refer to "**Connect to a SSH Server**")
5. (To stop): `jwt-agent --stop`

![demo-jwtagent](./asciinema/jwtagent.gif)

#### Option B: Using `oidc-agent`

1. Set `USE_JWT_AGENT=no` in `~/.hpcissh`.
2. (Optional) To use sub-system: Set `OIDC_ISSUER="https://metis-c.hpci.nii.ac.jp/auth/realms/HPCI"` in `~/.hpcissh`.
3. Starting agent: Run `eval $(oidc-agent-service use)`
4. Run `oidc-sshconf-hpci` and follow browser prompts.
    - Enter encryption password
    - Open URL in Web browser
    - Enter the code displayed on your terminal
    - Select your shibboleth IdP
    - Login your shibboleth IdP
    - Enter the One-time code
5. (Refer to "**Connect to a SSH Server**")
6. (To stop): `eval $(oidc-agent-service stop)`

![demo-oidcagent](./asciinema/oidcagent.gif)

### Step 2: Connect to a SSH Server

```bash
# Automatically resolve the remote login name
hpcissh <HOSTNAME>

# Specify a remote login name
hpcissh REMOTE_USER@<HOSTNAME>
```

---

## Commands Summary

- `hpciscp`: Secure copy (scp compatible)
- `hpcisftp`: Secure FTP (sftp compatible)
- `hpcissh-config-show`: Display current configuration
- `hpcissh-version`: Show version info
- `hpci-token`: Display current JWT
- `hpci-parse-token`: Parse and display JWT claims
- `hpci-get-userinfo`: Retrieve OIDC user information

---

## Configurable Parameters

Customize via environment variables or `~/.hpcissh`. Run `hpcissh-config-show` to display the current effective values.

| Parameter | Description (`Default value`) |
| :--- | :--- |
| `USE_JWT_AGENT` | Use `jwt-agent` instead of `oidc-agent` (`yes`) |
| `HPCISSH_DEBUG` | Enable debug mode (`no`) |
| `HPCISSH_DEBUG_X` | Run scripts with `set -x` (`no`) |
| `HPCISSH_QUIET` | Suppress warning messages (`no`) |
| `HPCISSH_PORT` | Destination SSH port (`2222`) |
| `HPCISSH_AUTO_KNOWN_HOSTS` | Automatically use HPCI SSH CA (`yes`) |
| `HPCISSH_AUTO_LOGIN_NAME` | Automatically resolve remote login name (`yes`) |
| `HPCISSH_TOKEN_INPUT` | Token input method: `sshpass` or `SSH_ASKPASS` (`sshpass`) |
| `OIDC_ISSUER` | OpenID Connect issuer URL for `oidc-agent` (`https://metis.hpci.nii.ac.jp/auth/realms/HPCI`) |
| `OIDC_AGENT_FORWARD` | Enable `oidc-agent` forwarding (`yes`) |
| `OIDC_AGENT_OPTS` | Options for `oidc-agent` via `hpci-oidc-agent-service` (`--no-autoreauthenticate`) |
| `OIDC_AGENT_CONF_NAME` | Account config name for `oidc-agent` (`hpci`) |
| `OIDC_AGENT_USE_PW_ENV` | Use `--pw-env` for `oidc-gen` and `oidc-add` to suppress GUI popup for `oidc-agent` on Desktop environment (`yes`) |
| `OIDC_AT_LEAST_VALID_TIME` | Min validity required for access token for `oidc-agent` (`180` sec.) |
| `OIDC_USERINFO_EXPIRE` | Lifetime of cached user info (`1800` sec.) |
| `OIDC_USERINFO_ENDPOINT` | Full URL for the userinfo endpoint. If this value is set,  OIDC_USERINFO_ENDPOINT_PATH is ignored (Default: `<empty string>`: automatically retrieved from the access token) |
| `OIDC_USERINFO_ENDPOINT_PATH` | Path to the userinfo endpoint (`/protocol/openid-connect/userinfo`) |

---

## For Developers

### Testing

Offline testing:

```bash
make build install test clean uninstall prefix=$(pwd)/LOCAL
```

Online testing (requires active agents):

```bash
# - (Run jwt-agent and oidc-agent before testing)

make build install prefix=$(pwd)/LOCAL
./run-tests.sh --prefix $(pwd)/LOCAL <TARGET_HOSTNAME>
```

### GitHub Actions

- Release-based Tagging: Creating a release with a `vX.Y.Z` tag automatically builds and pushes container images tagged as `X.Y.Z`, `X.Y`, and `latest`.
- Branch-based Builds: Container images are automatically generated upon pushing to the `main` and `develop` branches.
- CI Testing:
  - Pushes to any other branches trigger tests only (no image generation).
  - Tests are automatically executed for all pull requests.
