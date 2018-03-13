#!/usr/bin/env bash
#
# Construct a tarball containing the necessary GPG binaries.

set -euo pipefail

# shellcheck source=helper/log.sh
source "${SCRIPT}/helper/log.sh"

## Build the tarball ##################################################################################################

BUILD="${ROOT}/build"
DIST="${ROOT}/dist"
TARBALL="${DIST}/gnupg-macos.tar.gz"

mkdir -p "${DIST}"

cd "${BUILD}/gnupg"
tar zcvf "${TARBALL}" \
  bin/gpg \
  bin/gpg-agent

info "Built tarball at ${TARBALL}."
