#!/usr/bin/env bash
#
# Create a GitHub release for the current tag if one does not exist yet. Upload the packaged tarball and attach it.

set -euo pipefail

exec ${ROOT}/script/ruby/release-o-matic.rb \
  --version-file "${ROOT}/versions" \
  --upload "${ROOT}/dist/gnupg-macos.tar.gz"
