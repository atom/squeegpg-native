#!/usr/bin/env bash
#
# Build the current GPG version for MacOS.

set -euo pipefail

# shellcheck source=helper/log.sh
source "${SCRIPT}/helper/log.sh"

# shellcheck source=helper/prereq.sh
source "${SCRIPT}/helper/prereq.sh"

# shellcheck source=helper/title.sh
source "${SCRIPT}/helper/title.sh"

# shellcheck source=helper/module.sh
source "${SCRIPT}/helper/module.sh"

# shellcheck source=helper/paths.sh
source "${SCRIPT}/helper/paths.sh"

## Download and build prerequisites ###################################################################################

mkdir -p "${BUILD}"

module -n libgpg-error \
  -c enable-static -c disable-shared -c disable-rpath \
  -c disable-doc -c disable-tests -c disable-languages

module -n npth \
  -c enable-static -c disable-shared -c disable-tests

module -n libgcrypt \
  -c enable-static -c disable-shared \
  -c with-libgpg-error-prefix=${BUILD}/deps/libgpg-error \
  -c with-pth-prefix=${BUILD}/deps/npth

module -n libassuan \
  -c enable-static -c disable-shared -c disable-doc \
  -c with-libgpg-error-prefix=${BUILD}/deps/libgpg-error

module -n libksba \
  -c enable-static -c disable-shared \
  -c with-libgpg-error-prefix=${BUILD}/deps/libgpg-error

module -n pinentry \
  -c with-libgpg-error-prefix=${BUILD}/deps/libgpg-error \
  -c with-libassuan-prefix=${BUILD}/deps/libassuan

## Download and build GPG #############################################################################################

module -n gnupg \
  -f "$(${BUILD}/deps/libgcrypt/bin/libgcrypt-config --cflags)" \
  -c disable-gpgsm \
  -c disable-scdaemon \
  -c disable-dirmngr \
  -c disable-doc \
  -c disable-gpgtar \
  -c disable-photo-viewers \
  -c disable-rpath \
  -c with-libgpg-error-prefix="${BUILD}/deps/libgpg-error" \
  -c with-libgcrypt-prefix="${BUILD}/deps/libgcrypt" \
  -c with-libassuan-prefix="${BUILD}/deps/libassuan" \
  -c with-ksba-prefix="${BUILD}/deps/libksba" \
  -c with-npth-prefix="${BUILD}/deps/npth" \
  -o "${GPGOUT}"

title "✨ Build successful ✨"
