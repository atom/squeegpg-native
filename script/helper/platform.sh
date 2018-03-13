#!/usr/bin/env bash
#
# Infer the target platform, if not specified manually.

export TARGET_PLATFORM

function infer_platform {
  if [ -z "${TARGET_PLATFORM:-}" ]; then
    if [ -z "${OSTYPE:-}" ]; then
      error "OSTYPE is not available. Please set TARGET_PLATFORM manually."
      error "Currently supported TARGET_PLATFORM values: macos, linux."
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
        exit 1
        ;;
    esac

    verbose "Inferred target platform: [${TARGET_PLATFORM}]."
  fi
}
