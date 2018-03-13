#!/usr/bin/env bash
#
# Publish the current packaged distribution to a GitHub release.

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
    ${SCRIPT}/publish-macos.sh
    ;;
  linux)
    ${SCRIPT}/publish-linux.sh
    ;;
  *)
    error "Unsupported TARGET_PLATFORM: [${TARGET_PLATFORM}]."
    error "Please choose one of: macos, linux."
    exit 1
    ;;
esac
