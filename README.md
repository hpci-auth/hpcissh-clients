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

Choose one of the following methods:

- **[Case 1: Container](#case-1-using-container-for-podman-or-docker)** (Recommended): Use Podman or Docker. All dependencies are pre-installed.
- **[Case 2: macOS Native](#case-2-macos-native-package-via-homebrew)**: Install natively on macOS using Homebrew.
- **[Case 3: Manual Setup](#case-3-manual-setup)**: Build and install from source manually.

### Case 1: Using Container for Podman (or Docker)

This is the easiest way to get started without manually installing all dependencies.

**Note**: Podman operates without requiring root privileges
(rootless). In contrast, Docker typically runs with elevated
privileges. Please ensure you fully understand the security
implications of these permissions before using Docker.

**Disk Usage**: Using the container image consumes approximately 2 GB of disk space per user.

#### Demo: Deploying with Podman

![demo-podman](./asciinema/podman.gif)

#### OS-specific Podman Setup

- **WSL2 (Windows 11)**:
  - Install WSL2
    - English : <https://learn.microsoft.com/en-us/windows/wsl/install>
    - Japanese: <https://learn.microsoft.com/ja-jp/windows/wsl/install>
  - **Prerequisite**: Update to the latest WSL by running `wsl --update` in PowerShell, and then restart it with `wsl --shutdown`.
  - There are two ways to install Podman.
    - Please choose one of the following methods.
  - Option A: Install Podman within Ubuntu on WSL2
    - **Important**: Ensure `systemd` is enabled in your WSL distribution's `/etc/wsl.conf` (`systemd=true` under `[boot]`) and restart WSL (`wsl --shutdown`). Without this, Podman may fail with errors like `mkdir /run/user/1000: permission denied`.
    - Run `sudo apt-get update && sudo apt-get -y install podman`
  - Option B: Download Podman Installer (Podman CLI for Windows) from <https://podman.io/>
    - Run the installer and follow the on-screen instructions.
    - (In Powershell) Run `podman machine init` and `podman machine start`
- **macOS**:
  - There are two ways to install Podman.
    - Please choose one of the following methods.
  - Option A: Install Podman via Homebrew
    1. Install Homebrew: <https://brew.sh/>
    2. Run `brew install podman`
    3. Run `podman machine init && podman machine start`
  - Option B: Download Podman Installer (Podman CLI for macOS) from <https://podman.io/>
    - Run the installer and follow the on-screen instructions.
    - Run `podman machine init && podman machine start`
  - **Time Sync (macOS)**: If `oidc-agent` fails after sleep, the `podman machine` time might be out of sync. To fix it, run `podman machine ssh sudo chronyc -a makestep`. (Known issue: [#27293](https://github.com/containers/podman/issues/27293))
- **Linux Distributions**: Install Podman via the package manager
  - Debian / Ubuntu:
    - Run `sudo apt-get update && sudo apt-get -y install podman`
  - RHEL / RHEL-based (AlmaLinux / Rocky Linux / etc.):
    - Run `sudo dnf -y install podman`

For more details, refer to <https://podman.io/docs/installation>.

#### Common Procedures for Podman (or Docker)

1. **Start the Container**:
   Run the following command (it mounts your host's `$HOME` to `/HOST_HOMEDIR`):

    ```bash
    # Using Podman (recommended):
    podman run --userns=keep-id --replace \
      --detach-keys="ctrl-^" \
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
      --detach-keys="ctrl-^" \
      --rm -it --init --hostname hpcissh --name hpcissh \
      --mount type=bind,src=${HOME},dst=/HOST_HOMEDIR \
      -e USER_UID=$(id -u) \
      -e USER_GID=$(id -g) \
      -e USER_NAME=$(id -un) \
      ghcr.io/hpci-auth/hpcissh-almalinux10:latest
    ```

    ```powershell
    # If using Podman in Windows Powershell:
    PS C:\Users\USERNAME> podman run --userns=keep-id --replace `
        --detach-keys="ctrl-^" `
        --rm -it --init --hostname hpcissh --name hpcissh `
        --mount type=bind,src=${HOME},dst=/HOST_HOMEDIR `
        -e USER_UID=1000 `
        -e USER_GID=1000 `
        -e USER_NAME=USERNAME `
        ghcr.io/hpci-auth/hpcissh-almalinux10:latest
    ```

    - **Troubleshooting**: If you encounter cgroup-related errors, try adding `--cgroup-manager=cgroupfs` to the `podman run` command.
    - **Note for WSL2**: You can safely ignore the warning message `WARN[0000] "/" is not a shared mount, this could cause issues or missing mounts with rootless containers`.

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

#### (Advanced) Building and Customizing the Container Image Locally

```bash
cd docker
podman build -f Dockerfile-almalinux -t hpcissh-almalinux10:localdev \
  --build-arg ALMA_VERSION=10 \
  --build-arg OIDC_AGENT_VERSION=4.5.2 \
  --build-arg JWT_AGENT_VERSION=1.1.1 \
  ../
```

The container image is kept minimal by design. To add extra packages, you can use `microdnf install <package>` inside the container and rebuild the image locally.

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

(Requires sudo; installs to `/usr/local` by default)

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

Note: On macOS, `/bin/bash` is Bash version 3.

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

The following files are managed automatically by `hpci-oidc-agent-service`:

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

1. Set `USE_JWT_AGENT=yes` (yes is default) in `~/.hpcissh`.
2. Log in to the HPCI JWT server: [elpis (main-system)](https://elpis.hpci.nii.ac.jp) or [elpis-c (sub-system)](https://elpis-c.hpci.nii.ac.jp).
3. Generate a JWT and copy the provided **command line** and **passphrase** to your clipboard.
4. Run `jwt-agent -s <JWT_SERVER_URL> -l <USER_NAME>` and enter the **passphrase**.
5. (Refer to [Step 2: Connect to a SSH Server](#step-2-connect-to-a-ssh-server))
6. (To stop): Run `jwt-agent --stop`

![demo-jwtagent](./asciinema/jwtagent.gif)

#### Option B: Using `oidc-agent`

1. Set `USE_JWT_AGENT=no` in `~/.hpcissh`.
2. (Optional) To use sub-system: Set `OIDC_ISSUER="https://metis-c.hpci.nii.ac.jp/auth/realms/HPCI"` in `~/.hpcissh`.
3. Starting agent: Run the following command to start oidc-agent and set environment variables.

    ```bash
    eval `hpci-oidc-agent-service use`
    ```

4. Run `oidc-sshconf-hpci` and follow browser prompts.
    - Enter encryption password
    - Open URL in Web browser
    - Enter the code displayed on your terminal
    - Select your shibboleth IdP
    - Login your shibboleth IdP
    - Enter the One-time code
5. (Refer to [Step 2: Connect to a SSH Server](#step-2-connect-to-a-ssh-server))
6. (To stop): Run the following command to stop oidc-agent and unset environment variables.

    ```bash
    eval `hpci-oidc-agent-service stop`
    ```

![demo-oidcagent](./asciinema/oidcagent.gif)

### Step 2: Connect to a SSH Server

```bash
# Automatically resolve the remote login name
hpcissh <HOSTNAME>

# Specify a remote login name
hpcissh REMOTE_USER@<HOSTNAME>
```

To log out of the remote machine, run the `exit` command.

### Note: Using `hpciscp` in the Container

In the container-based setup, your host OS's home directory is mounted at `~/HOST_HOMEDIR/` inside the container. You can use this directory to transfer files between the remote server and your host machine.

Example: To download `/path/to/myfile.txt` from the remote server to your host's `~/Downloads/myfile.txt`:

```bash
hpciscp <HOSTNAME>:/path/to/myfile.txt ~/HOST_HOMEDIR/Downloads/myfile.txt
```

Example: To upload `~/myfile.txt` from your host to the remote server's `/path/to/myfile.txt`:

```bash
hpciscp ~/HOST_HOMEDIR/myfile.txt <HOSTNAME>:/path/to/myfile.txt
```

**Warning**: Any files stored strictly within the container's internal filesystem are volatile and will be deleted automatically when the container exits. Always copy important data to `~/HOST_HOMEDIR/` for permanent storage.

---

## Commands Summary

- `hpcissh`: Secure Shell client for HPCI
- `hpciscp`: Secure copy (scp compatible)
- `hpcisftp`: Secure FTP (sftp compatible)
- `hpcissh-config-show`: Display current configuration
- `hpcissh-append-ssh-ca`: Manage SSH CA for HPCI
- `hpcissh-version`: Show version info
- `hpci-oidc-agent-service`: Service wrapper for oidc-agent
- `oidc-sshconf-hpci`: Configure HPCI issuer profile for oidc-agent
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

#### Offline testing

```bash
# For Linux:
make build install test clean uninstall prefix=$(pwd)/LOCAL

# For macOS:
make build install test clean uninstall prefix=$(pwd)/LOCAL bash_path=$(brew --prefix)/bin/bash
```

#### Online testing (requires active agents)

```bash
# (Run jwt-agent and oidc-agent before testing)
# jwt-agent ...
# eval `oidc-agent-service use`
# ...

# Prepare or Linux:
make build install prefix=$(pwd)/LOCAL

# Prepare for macOS:
make build install prefix=$(pwd)/LOCAL bash_path=$(brew --prefix)/bin/bash

# Run tests
./run-tests.sh --prefix $(pwd)/LOCAL <TARGET_HOSTNAME>
```

#### Container testing

```bash
cd docker
make build
make test
```

### GitHub Actions

- Release-based Tagging: Creating a release with a `vX.Y.Z` tag automatically builds and pushes container images tagged as `X.Y.Z`, `X.Y`, and `latest`.
- Branch-based Builds: Container images are automatically generated upon pushing to the `main` and `develop` branches.
- CI Testing:
  - Pushes to any other branches trigger tests only (no image generation).
  - Tests are automatically executed for all pull requests.
