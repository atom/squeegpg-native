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
infer_platform

# shellcheck source=helper/paths.sh
source "${SCRIPT}/helper/paths.sh"

## Build the tarball ##################################################################################################

mkdir -p "${DIST}"

cd "${GPGOUT}"
tar zcvf "${TARBALL}" "${REL_BINARIES[@]}"
info "Built tarball at ${TARBALL}."
