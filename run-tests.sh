#!/bin/bash

set -Eu

usage() {
    local exit_code="${1:-1}"  # 1: error
    if [ "$exit_code" -ne 0 ]; then
        exec 1>&2
    fi
    echo "Usage: $0 REMOTE_HOST [--run] [--prefix PREFIX]"
    echo "  --run            Actually run tests (Default: dry run)"
    echo "  --prefix PREFIX  Installed prefix of hpcissh"
    echo "  -h|--help        Show this help message"
    exit "$exit_code"
}

RUN=false
HPCISSH_CMD=hpcissh
HPCISCP_CMD=hpciscp
HPCISFTP_CMD=hpcisftp
HPCISSH_VER_CMD=hpcissh-version
GET_USERINFO_CMD=hpci-get-userinfo
PARSE_TOKEN_CMD=hpci-parse-token
HPCI_TOKEN_CMD=hpci-token
CONFIG_SHOW_CMD=hpcissh-config-show

# (SKIP tests)
# oidc-sshconf
# oidc-sshconf-hpci
# oidc-token-hpci
# hpcissh-append-ssh-ca
# hpci-oidc-agent-service

REMOTE_HOST=

while [ $# -gt 0 ]; do
    case "$1" in
        --run)
            RUN=true
            shift
            ;;
        --prefix)
            PREFIX="$2"
            shift 2
            HPCISSH_CMD="${PREFIX}/bin/hpcissh"
            HPCISCP_CMD="${PREFIX}/bin/hpciscp"
            HPCISFTP_CMD="${PREFIX}/bin/hpcisftp"
            HPCISSH_VER_CMD="${PREFIX}/bin/hpcissh-version"
            GET_USERINFO_CMD="${PREFIX}/bin/hpci-get-userinfo"
            PARSE_TOKEN_CMD="${PREFIX}/bin/hpci-parse-token"
            HPCI_TOKEN_CMD="${PREFIX}/bin/hpci-token"
            CONFIG_SHOW_CMD="${PREFIX}/bin/hpcissh-config-show"
            ;;
        -h|--help)
            usage 0
            ;;
        *)
            if [ -z "${REMOTE_HOST}" ]; then
                REMOTE_HOST="$1"
                shift
            else
                echo "Error: Unknown argument '$1'"
                usage 1
            fi
            ;;
    esac
done

error_handler() {
    set +x
    local code=$1
    local line=$2
    local command=$3

    echo "------------------------------------------------"
    echo "  [ERROR]"
    echo "  Line:    $line"
    echo "  Command: $command"
    echo "  Status:  $code"
    echo "------------------------------------------------"
    exit "$code"
}

TESTFILE_NAME=hpcissh_testfile_${UID}_$$
TESTFILE_REMOTE_NAME=_hpcissh_testfile

TESTFILE_PATH_1="/tmp/${TESTFILE_NAME}-1"
TESTFILE_PATH_2="/tmp/${TESTFILE_NAME}-2"

clean() {
    set -x
    rm -f "${TESTFILE_PATH_1}"
    rm -f "${TESTFILE_PATH_2}"
}

trap 'error_handler $? $LINENO "$BASH_COMMAND"' ERR
trap clean EXIT

GREEN=$'\033[1;32m'
YELLOW=$'\033[1;33m'
OFF=$'\033[0m'

dryrun() {
    echo "${YELLOW}[DRYRUN]" "${@}" "${OFF}"
}

run() {
    echo "${GREEN}[RUN]" "${@}" "${OFF}"
    "${@}"
}

if ${RUN}; then
    DR=run
else
    DR=dryrun
fi

${DR} "${HPCISSH_VER_CMD}"
${DR} "${CONFIG_SHOW_CMD}"

test_common() {
    ${DR} "${GET_USERINFO_CMD}"
    ${DR} "${HPCI_TOKEN_CMD}"
    ${DR} echo
    ${DR} "${PARSE_TOKEN_CMD}"

    # hpcissh
    ${DR} sleep 1
    ${DR} "${HPCISSH_CMD}" "${REMOTE_HOST}" hostname

    # hcpiscp
    openssl rand -base64 12 | tee "${TESTFILE_PATH_1}"
    ${DR} sleep 1
    ${DR} "${HPCISCP_CMD}" "${TESTFILE_PATH_1}" "${REMOTE_HOST}":"${TESTFILE_REMOTE_NAME}"
    ${DR} sleep 1
    ${DR} "${HPCISCP_CMD}" "${REMOTE_HOST}":"${TESTFILE_REMOTE_NAME}" "${TESTFILE_PATH_2}"
    ${DR} diff "${TESTFILE_PATH_1}" "${TESTFILE_PATH_2}"

    # hpcisftp
    openssl rand -base64 12 | tee "${TESTFILE_PATH_1}"
    # NOTE: sftp args cannnot upload a file
    ${DR} sleep 1
    ${DR} "${HPCISCP_CMD}" "${TESTFILE_PATH_1}" "${REMOTE_HOST}":"${TESTFILE_REMOTE_NAME}"
    ${DR} sleep 1
    ${DR} "${HPCISFTP_CMD}" "${REMOTE_HOST}":"${TESTFILE_REMOTE_NAME}" "${TESTFILE_PATH_2}"
    ${DR} diff "${TESTFILE_PATH_1}" "${TESTFILE_PATH_2}"
}

${DR} export USE_JWT_AGENT=yes
test_common

${DR} export USE_JWT_AGENT=no
test_common

echo "All tests passed."
