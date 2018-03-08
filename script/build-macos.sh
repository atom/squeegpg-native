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

function depversion {
  local DEP=$1

  sed -n -e "s/^${DEP}:[[:space:]]*\([[:digit:]][[:digit:].]*\)/\\1/p" "${ROOT}/versions"
}

function depurl {
  local DEP=$1

  printf "https://gnupg.org/ftp/gcrypt/${DEP}/${DEP}-$(depversion ${DEP}).tar.bz2"
}

function depargs {
  local DEP=$1

  case "${DEP}" in
    libgpg-error)
      printf -- "--disable-doc --disable-tests --disable-languages"
      ;;
    npth)
      printf -- "--disable-tests"
      ;;
    libgcrypt)
      printf -- \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error " \
        "--with-pth-prefix=${ROOT}/build/deps/npth "
      ;;
    libassuan)
      printf -- \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error " \
        "--disable-doc"
      ;;
    libksba)
      printf -- \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error"
      ;;
    pinentry)
      printf -- \
        "--with-libgpg-error-prefix=${ROOT}/build/deps/libgpg-error " \
        "--with-libassuan-prefix=${ROOT}/build/deps/libassuan"
      ;;
    *)
      ;;
  esac
}

for DEP in libgpg-error npth libgcrypt libassuan libksba pinentry; do
  DEPVERSION="$(depversion ${DEP})"
  if [ -z "${DEPVERSION}" ]; then
    error "Unable to find the version of ${DEP}."
    error "Please add a line like the following to ${ROOT}/versions:"
    error "  ${DEP}: x.y.z"
    exit 1
  fi
  title "Building ${DEP} ${DEPVERSION}"
  info "${DEP} version ${DEPVERSION}"

  DEPSRC="${ROOT}/deps/${DEP}-${DEPVERSION}"
  DEPTARBALL="${ROOT}/deps/${DEP}-${DEPVERSION}.tar.bz2"
  DEPTARGET="${ROOT}/build/deps/${DEP}"
  MARKFILE="${DEPTARGET}/.success"

  mkdir -p ${ROOT}/deps/

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
    cd "${ROOT}/deps"
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
