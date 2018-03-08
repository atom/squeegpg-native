#!/usr/bin/env bash
#
# Utilities to ensure the availability of build system prerequisites.

function has {
  local TOOLNAME=$1

  if type "${TOOLNAME}" >/dev/null 2>&1; then
    verbose "found ${TOOLNAME}."
    return 0
  else
    error "unable to find ${TOOLNAME}."
    return 1
  fi
}
