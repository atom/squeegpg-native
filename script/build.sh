#!/usr/bin/env bash
#
# Download or build GPG for the current platform.

set -euo pipefail

## Get our bearings in the filesystem #################################################################################

export ROOT
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

export SCRIPT="${ROOT}/script"
export GPGROOT="${ROOT}/gnupg"

## Source helpers ####################################################################################################

# shellcheck source=helper/log.sh
source "${SCRIPT}/helper/log.sh"

## Infer the target platform ##########################################################################################

if [ -z "${TARGET_PLATFORM:-}" ]; then
  if [ -z "${OSTYPE:-}" ]; then
    error "OSTYPE is not available. Please set TARGET_PLATFORM manually."
    error "Currently supported TARGET_PLATFORM values: macos."
    exit 1
  fi

  case "${OSTYPE}" in
    darwin*)
      TARGET_PLATFORM=macos
      ;;
    linux*)
      TARGET_PLATFORM=linux
      ;;
    *)
      error "Unsupported OSTYPE: [${OSTYPE}]."
      ;;
  esac

  verbose "Inferred target platform: [${TARGET_PLATFORM}]."
fi

## Dispatch to platform build script ##################################################################################

case "${TARGET_PLATFORM}" in
  macos)
    ${SCRIPT}/build-macos.sh
    ;;
  linux)
    ${SCRIPT}/build-linux.sh
    ;;
  *)
    error "Unsupported TARGET_PLATFORM: [${TARGET_PLATFORM}]."
    error "Please choose one of: macos."
    exit 1
    ;;
esac
