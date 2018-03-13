#!/usr/bin/env bash
#
# Analyze the binaries produced by build.sh.

set -euo pipefail

## Get our bearings in the filesystem #################################################################################

export ROOT
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

export SCRIPT="${ROOT}/script"

## Source helpers ####################################################################################################

# shellcheck source=helper/log.sh
source "${SCRIPT}/helper/log.sh"

# shellcheck source=helper/platform.sh
source "${SCRIPT}/helper/platform.sh"

# shellcheck source=helper/paths.sh
source "${SCRIPT}/helper/paths.sh"

## Dispatch to platform package script #################################################################################

infer_platform

IFS=" " read -r -a ARGS <<< "$(get_binaries --absolute --binary)"
cd "${SCRIPT}/ruby"
which chruby >/dev/null 2>&1 && chruby 2.4.2
bundle exec ruby ./analyzer.rb "${ARGS[@]}"
