#!/usr/bin/env bash
#
# Publish the current packaged distribution to a GitHub release.

set -euo pipefail

## Get our bearings in the filesystem #################################################################################

export ROOT
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

export SCRIPT="${ROOT}/script"

## Source helpers #####################################################################################################

# shellcheck source=helper/log.sh
source "${SCRIPT}/helper/log.sh"

# shellcheck source=helper/platform.sh
source "${SCRIPT}/helper/platform.sh"
infer_platform

# shellcheck source=helper/paths.sh
source "${SCRIPT}/helper/paths.sh"

## Create or amend the release ########################################################################################

cd "${SCRIPT}/ruby/"
bundle exec ./release-o-matic.rb \
  --version-file "${ROOT}/versions" \
  --upload "${TARBALL}"
