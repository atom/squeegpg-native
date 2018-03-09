#!/usr/bin/env bash

function getversion {
  local MOD=$1

  sed -n -e "s/^${MOD}:[[:space:]]*\([[:digit:]][[:digit:].]*\)/\\1/p" "${ROOT}/versions"
}

function module {
  local OPTIND=1
  local OPT
  local OPTARG

  local NAME
  local VERSION
  local URL
  local SRCDIR
  local TARBALL
  local OUTDIR=""
  local CONFIGURE_ARGS=("--disable-dependency-tracking")
  local EXTRA_CFLAGS=()
  local MARKFILE

  while getopts ":n:c:f:o:" OPT; do
    case ${OPT} in
      n)
        NAME=${OPTARG}
        ;;
      c)
        CONFIGURE_ARGS+=("--${OPTARG}")
        ;;
      f)
        EXTRA_CFLAGS+=("${OPTARG}")
        ;;
      o)
        OUTDIR="${OPTARG}"
        ;;
      \?)
        error "module: Invalid option -${OPTARG}."
        return 1
        ;;
      :)
        error "module: Option -${OPTARG} requires an argument."
        return 1
        ;;
    esac

    if [ -z "${NAME}" ]; then
      error "module: Option -n is required."
      return 1
    fi

    title "Building ${NAME} version ${VERSION}"

    VERSION=$(getversion ${NAME})

    if [ -z "${VERSION}" ]; then
      error "Unable to find the version of ${NAME}."
      error "Please add a line like the following to ${ROOT}/versions:"
      error "  ${NAME}: x.y.z"
      return 1
    fi

    URL="https://gnupg.org/ftp/gcrypt/${NAME}/${NAME}-${VERSION}.tar.bz2"
    SRCDIR="${ROOT}/src/${NAME}-${VERSION}"
    TARBALL="${ROOT}/src/${NAME}-${VERSION}.tar.bz2"
    [ -z "${OUTDIR}" ] && OUTDIR="${ROOT}/build/deps/${NAME}"
    MARKFILE="${OUTDIR}/.success"

    mkdir -p ${ROOT}/src/

    if [ -d "${SRCDIR}" ] || [ -f "${TARBALL}" ]; then
      verbose "Module ${NAME} has already been downloaded."
    else
      info "Downloading tarball for ${NAME}."
      curl --silent --fail --output "${TARBALL}" "${URL}" || {
        error "Unable to download ${NAME} from URL:"
        error "${URL}"
        exit 1
      }
    fi

    if [ -d "${SRCDIR}" ]; then
      verbose "Module ${NAME} has already been unpacked."
    else
      info "Unpacking tarball for ${NAME}."
      cd "${ROOT}/src" || return 1
      tar xjf "${TARBALL}"
    fi

    if [ -f "${MARKFILE}" ]; then
      verbose "Module ${NAME} has already been built."
      return 0
    fi

    mkdir -p "${OUTDIR}"
    cd "${SRCDIR}" || return 1

    info "Building dependency ${NAME}."

    verbose "configure"
    export CFLAGS
    CFLAGS="${EXTRA_CFLAGS[*]-}"
    sh ./configure --prefix="${OUTDIR}" "${CONFIGURE_ARGS[@]-}"

    verbose "make"
    make

    verbose "make install"
    make install

    info "Successfully build ${NAME}."
    touch "${MARKFILE}"
  done
}
