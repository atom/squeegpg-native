#!/usr/bin/env bash
#
# Package a GPG build for distribution.

set -euo pipefail

## Get our bearings in the filesystem #################################################################################

export ROOT
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

export SCRIPT="${ROOT}/script"
export GPGROOT="${ROOT}/gnupg"

## Source helpers ####################################################################################################

# shellcheck source=helper/log.sh
source "${SCRIPT}/helper/log.sh"

# shellcheck source=helper/platform.sh
source "${SCRIPT}/helper/platform.sh"

## Dispatch to platform package script #################################################################################

infer_platform

case "${TARGET_PLATFORM}" in
  macos)
    ${SCRIPT}/package-macos.sh
    ;;
  linux)
    ${SCRIPT}/package-linux.sh
    ;;
  *)
    error "Unsupported TARGET_PLATFORM: [${TARGET_PLATFORM}]."
    error "Please choose one of: macos, linux."
    exit 1
    ;;
esac
