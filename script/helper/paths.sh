#!/usr/bin/env bash

export BUILD="${ROOT}/build"
export GPGOUT="${BUILD}/gnupg"
export DIST="${ROOT}/dist"
export TARBALL

REL_BINARIES=()

if [ -z "${TARGET_PLATFORM:-}" ]; then
  infer_platform
fi

case "${TARGET_PLATFORM}" in
  macos)
    TARBALL="${DIST}/gnupg-macos.tar.gz"
    REL_BINARIES=(bin/gpg bin/gpg-agent)
    ;;
  linux)
    TARBALL="${DIST}/gnupg-linux.tar.gz"
    REL_BINARIES=(bin/gpg bin/gpg-agent)
    ;;
  *)
    ;;
esac

function get_binaries {
  local BASE=""
  if [ "${1:-}" = "--absolute" ]; then
    BASE="${GPGOUT}/"
    shift
  fi

  local PREFIX=${1:-}
  if [ -n "${PREFIX}" ]; then
    PREFIX="${PREFIX} "
  fi

  for REL_BIN in "${REL_BINARIES[@]}"; do
    printf "%s%s%s " "${PREFIX}" "${BASE}" "${REL_BIN}"
  done
}
