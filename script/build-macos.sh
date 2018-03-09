#!/usr/bin/env bash
#
# Build the current GPG version for MacOS.

set -euo pipefail

mkdir -p "${ROOT}/build"

# shellcheck source=helper/log.sh
source "${SCRIPT}/helper/log.sh"

# shellcheck source=helper/prereq.sh
source "${SCRIPT}/helper/prereq.sh"

# shellcheck source=helper/title.sh
source "${SCRIPT}/helper/title.sh"

# shellcheck source=helper/module.sh
source "${SCRIPT}/helper/module.sh"

## Download and build prerequisites ###################################################################################

module -n libgpg-error \
  -c enable-static -c disable-shared -c disable-rpath \
  -c disable-doc -c disable-tests -c disable-languages

module -n npth \
  -c enable-static -c disable-shared -c disable-tests

module -n libgcrypt \
  -c enable-static -c disable-shared \
  -c with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error \
  -c with-pth-prefix=${ROOT}/build/deps/npth

module -n libassuan \
  -c enable-static -c disable-shared -c disable-doc \
  -c with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error

module -n libksba \
  -c enable-static -c disable-shared \
  -c with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error

module -n pinentry \
  -c with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error \
  -c with-libassuan-prefix=${ROOT}/build/deps/libassuan

## Download and build GPG #############################################################################################

module -n gnupg \
  -f "$(${ROOT}/build/deps/libgcrypt/bin/libgcrypt-config --cflags)" \
  -c disable-gpgsm \
  -c disable-scdaemon \
  -c disable-dirmngr \
  -c disable-doc \
  -c disable-gpgtar \
  -c disable-photo-viewers \
  -c disable-rpath \
  -c with-libgpg-error-prefix="${ROOT}/build/deps/libgpg-error" \
  -c with-libgcrypt-prefix="${ROOT}/build/deps/libgcrypt" \
  -c with-libassuan-prefix="${ROOT}/build/deps/libassuan" \
  -c with-ksba-prefix="${ROOT}/build/deps/libksba" \
  -c with-npth-prefix="${ROOT}/build/deps/npth" \
  -o "${ROOT}/build/gnupg"

info "Dynamic dependencies of the GPG binaries:"

for BINARY in ${ROOT}/build/gnupg/bin/*; do
  otool -L "${BINARY}"
done

title "✨ Build successful ✨"
