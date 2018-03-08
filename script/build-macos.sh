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

## Verify build prerequisites #########################################################################################

has automake

## Download and build prerequisites ###################################################################################

function getversion {
  local DEP=$1

  sed -n -e "s/^${DEP}:[[:space:]]*\([[:digit:]][[:digit:].]*\)/\\1/p" "${ROOT}/versions"
}

function depurl {
  local DEP=$1

  printf "https://gnupg.org/ftp/gcrypt/${DEP}/${DEP}-$(getversion ${DEP}).tar.bz2"
}

function depargs {
  local DEP=$1

  case "${DEP}" in
    libgpg-error)
      echo -n \
        "--enable-static --disable-shared --disable-rpath " \
        "--disable-doc --disable-tests --disable-languages"
      ;;
    npth)
      echo -n \
        "--enable-static --disable-shared " \
        "--disable-tests"
      ;;
    libgcrypt)
      echo -n \
        "--enable-static --disable-shared " \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error " \
        "--with-pth-prefix=${ROOT}/build/deps/npth "
      ;;
    libassuan)
      echo -n \
        "--enable-static --disable-shared " \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error " \
        "--disable-doc"
      ;;
    libksba)
      echo -n \
        "--enable-static --disable-shared " \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error"
      ;;
    pinentry)
      echo -n \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error " \
        "--with-libassuan-prefix=${ROOT}/build/deps/libassuan"
      ;;
    *)
      ;;
  esac
}

for DEP in libgpg-error npth libgcrypt libassuan libksba pinentry; do
  DEPVERSION="$(getversion ${DEP})"
  if [ -z "${DEPVERSION}" ]; then
    error "Unable to find the version of ${DEP}."
    error "Please add a line like the following to ${ROOT}/versions:"
    error "  ${DEP}: x.y.z"
    exit 1
  fi
  title "Building ${DEP} ${DEPVERSION}"
  info "${DEP} version ${DEPVERSION}"

  DEPSRC="${ROOT}/src/${DEP}-${DEPVERSION}"
  DEPTARBALL="${ROOT}/src/${DEP}-${DEPVERSION}.tar.bz2"
  DEPTARGET="${ROOT}/build/deps/${DEP}"
  MARKFILE="${DEPTARGET}/.success"

  mkdir -p ${ROOT}/src/

  if [ -d "${DEPSRC}" ] || [ -f "${DEPTARBALL}" ]; then
    verbose "Dependency ${DEP} has already been downloaded."
  else
    info "Downloading tarball for ${DEP}."
    curl --silent --fail --output "${DEPTARBALL}" "$(depurl ${DEP})" || {
      error "Unable to download ${DEP} from URL:"
      error "$(depurl ${DEP})"
      exit 1
    }
  fi

  if [ -d "${DEPSRC}" ]; then
    verbose "Dependency ${DEP} has already been unpacked."
  else
    info "Unpacking tarball for ${DEPSRC}."
    cd "${ROOT}/src"
    tar xjf "${DEPTARBALL}"
  fi

  if [ -f "${MARKFILE}" ]; then
    verbose "Dependency ${DEP} has already been built."
    continue
  fi

  IFS=" " read -r -a CONFIGURE_ARGS <<< "$(depargs ${DEP})"

  mkdir -p "${DEPTARGET}"

  cd "${DEPSRC}"
  info "Building dependency ${DEP}."
  verbose "configure"
  sh ./configure --prefix="${DEPTARGET}" "${CONFIGURE_ARGS[@]-}" \
    --disable-dependency-tracking
  verbose "make"
  make
  verbose "make install"
  make install
  info "Successfully build ${DEP}."
  touch "${MARKFILE}"
done

## Download and build GPG #############################################################################################

GPGVERSION=$(getversion gnupg)
if [ -z "${GPGVERSION}" ]; then
  error "Unable to find the version of GPG to build."
  error "Please add a line like the following to ${ROOT}/versions:"
  error "  gnupg: x.y.z"
  exit 1
fi

title "Building gpg ${GPGVERSION}"
info "GPG version ${GPGVERSION}"

GPGSRC="${ROOT}/src/gnupg-${GPGVERSION}"
GPGURL="https://gnupg.org/ftp/gcrypt/gnupg/gnupg-${GPGVERSION}.tar.bz2"
GPGTARBALL="${ROOT}/src/gnupg-${GPGVERSION}.tar.bz2"
GPGTARGET="${ROOT}/build/gnupg"
MARKFILE="${GPGTARGET}/.success"

if [ -d "${GPGSRC}" ] || [ -f "${GPGTARBALL}" ]; then
  verbose "GPG has already been downloaded"
else
  info "Downloading GPG tarball."
  curl --silent --fail --output "${GPGTARBALL}" "${GPGURL}" || {
    error "Unable to download GPG from URL:"
    error "${GPGURL}"
    exit 1
  }
fi

if [ -d "${GPGSRC}" ]; then
  verbose "GPG has already been unpacked."
else
  info "Unpacking tarball for GPG."
  cd "${ROOT}/src"
  tar xjf "${GPGTARBALL}"
fi

if [ -f "${MARKFILE}" ]; then
  verbose "GPG has already been built."
else
  mkdir -p "${GPGTARGET}"

  cd "${GPGSRC}"
  info "Building GPG."

  verbose "configure"

  # Workaround for missing libgcrypt include
  export CFLAGS
  CFLAGS=$(${ROOT}/build/deps/libgcrypt/bin/libgcrypt-config --cflags)

  sh ./configure --prefix="${GPGTARGET}" \
    --with-libgpg-error-prefix="${ROOT}/build/deps/libgpg-error" \
    --with-libgcrypt-prefix="${ROOT}/build/deps/libgcrypt" \
    --with-libassuan-prefix="${ROOT}/build/deps/libassuan" \
    --with-ksba-prefix="${ROOT}/build/deps/libksba" \
    --with-npth-prefix="${ROOT}/build/deps/npth" \
    --disable-dependency-tracking \
    --disable-gpgsm \
    --disable-scdaemon \
    --disable-dirmngr \
    --disable-doc \
    --disable-gpgtar \
    --disable-photo-viewers \
    --disable-rpath

  verbose "make"
  make

  verbose "make install"
  make install

  info "Successfully build GPG."
  touch "${MARKFILE}"
fi

info "Dynamic dependencies of the GPG binaries:"

for BINARY in ${GPGTARGET}/bin/*; do
  otool -L "${BINARY}"
done

title "✨ Build successful ✨"
