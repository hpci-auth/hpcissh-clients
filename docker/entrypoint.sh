#!/bin/bash
set -eu -o pipefail

if [ "${DEBUG_X:-}" = yes ]; then
    set -x
fi

ENTRYPOINT_D=/entrypoint.d
INITFILE=/_entrypoint-init

usage() {
    if [ -n "${1:-}" ]; then
        echo "Error: ${1:-} is required"
    fi
    echo "Usage(example): podman(or docker) run -it --rm --name hpcissh \\"
    echo "  --mount type=bind,src=\${HOME},dst=/HOST_HOMEDIR \\"
    echo "  --env USER_UID=\$(id -u) \\"
    echo "  --env USER_GID=\$(id -g) \\"
    echo "  --env USER_NAME=\$(id -un)"
    echo "Overridable variables for --env:"
    echo "  MOUNT_HOST_HOME (default: /HOST_HOMEDIR)"
    echo "  CONTAINER_HOME  (default: /home/\${USER_NAME}"
    echo "  CONTAINER_SHELL (default: /bin/bash)"
    echo "  LANG            (default: ja_JP.UTF-8)"
    echo "  TZ              (default: Asia/Tokyo)"
}

# Required
[ -z "${USER_UID:-}" ] && usage USER_UID && exit 1
[ -z "${USER_GID:-}" ] && usage USER_GID && exit 1
[ -z "${USER_NAME:-}" ] && usage USER_NAME && exit 1

# Overridable
MOUNT_HOST_HOME=${MOUNT_HOST_HOME:-/HOST_HOMEDIR}
CONTAINER_HOME=${CONTAINER_HOME:-/home/${USER_NAME}}
CONTAINER_SHELL=${CONTAINER_SHELL:-/bin/bash}

# Variables
SYMLNK_HOST_HOME="${CONTAINER_HOME}/HOST_HOMEDIR"

copy_skel() {
    local u="$1"
    local g="$2"
    local h="$3"
    local f
    (
        shopt -s dotglob
        for f in "/etc/skel/"*; do
            [[ -e "$f" ]] || continue
            local bname
            bname=$(basename "$f")
            local dst="$h/$bname"
            if [ ! -f "$dst" ]; then
                cp -a "$f" "$dst"
                chown "$u:$g" "$dst"
            fi
        done
    )  # end of shopt
}

is_rhel_family() {
  local id_like="$1"

  if [[ "$id_like" =~ (^|[[:space:]])"rhel"([[:space:]]|$) ]]; then
    return 0
  else
    return 1
  fi
}

if [ ! -f $INITFILE ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    ID_LIKE="${ID_LIKE:-}"

    if is_rhel_family "$ID_LIKE"; then
        SUDO_GROUP=wheel
    else
        SUDO_GROUP=sudo
    fi

    if [ ! -d "$CONTAINER_HOME" ]; then
        mkdir -p "$CONTAINER_HOME"
        chown "$USER_UID:$USER_GID" "$CONTAINER_HOME"
        copy_skel "$USER_UID" "$USER_GID" "$CONTAINER_HOME"
    fi

    # For useradd warning: USERNAME's uid 501 outside of the UID_MIN 1000 and UID_MAX 60000 range.
    sed -i 's/^UID_MIN.*/UID_MIN              500/' /etc/login.defs
    sed -i 's/^GID_MIN.*/GID_MIN              500/' /etc/login.defs

    existing_user=$(id -un "${USER_UID}" 2> /dev/null || :)
    if [ -n "$existing_user" ] && [ "$existing_user" != "$USER_NAME" ]; then
        userdel "$existing_user"
    fi
    if ! getent group "$USER_GID" > /dev/null; then
        groupadd -g "$USER_GID" "$USER_NAME"
    fi
    if getent passwd "$USER_NAME" > /dev/null; then
        usermod -u "$USER_UID" -g "$USER_GID" -G "$SUDO_GROUP" -s "$CONTAINER_SHELL" -d "$CONTAINER_HOME" "$USER_NAME"
    else
        useradd -u "$USER_UID" -g "$USER_GID" -G "$SUDO_GROUP" -s "$CONTAINER_SHELL" -d "$CONTAINER_HOME" -M "$USER_NAME"
    fi
    echo "%${SUDO_GROUP} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${SUDO_GROUP}_nopasswd"
    chmod 0440 "/etc/sudoers.d/${SUDO_GROUP}_nopasswd"

    ### Workaround for "sudo: PAM account management error: Authentication service cannot retrieve authentication info"
    chmod u+r /etc/shadow

    touch $INITFILE
fi

if [ "$MOUNT_HOST_HOME" != "$CONTAINER_HOME" ]; then
    if [ -h "$SYMLNK_HOST_HOME" ]; then
        rm -f "$SYMLNK_HOST_HOME"
    fi
    if [ ! -e "$SYMLNK_HOST_HOME" ]; then
        ln -s "$MOUNT_HOST_HOME" "$SYMLNK_HOST_HOME"
    fi
fi

if [ -d "$ENTRYPOINT_D" ]; then
    for f in $(find $ENTRYPOINT_D -follow -type f -print | sort -V); do
        epfile="$f"
        case "$f" in
            *.envsh)
                # shellcheck disable=SC1090
                source "$epfile"
                ;;
            *.sh)
                "$epfile"
                ;;
            *)
                echo >&2 "INFO: $epfile: ignored"
                ;;
        esac
    done
fi

# For jwt-agent
/usr/sbin/syslog-ng --no-caps -f /etc/syslog-ng/hpci-syslog-ng.conf

if [ "$1" = "__DEFAULT__" ]; then
    exec /usr/local/bin/gosu "$USER_NAME" /bin/sh -c "cd ~ && ${CONTAINER_SHELL}"
else
    exec /usr/local/bin/gosu "$USER_NAME" "$@"
fi
