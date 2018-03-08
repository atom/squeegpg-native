#!/usr/bin/env bash
#
# Log things consistently with pretty colors.

function verbose {
  local MESSAGE=$1
  if [ -n "${VERBOSE:-}" ]; then
    printf "\033[0;37m[--]\033[0m %s\n" "${MESSAGE}"
  fi
}

function info {
  local MESSAGE=$1
  printf "\[\033[1;36m\][==]\[\033[0m\] %s\n" "${MESSAGE}"
}

function warning {
  local MESSAGE=$1
  printf "\[\033[1;33m\][!!]\[\033[0m\] %s\n" "${MESSAGE}"
}

function error {
  local MESSAGE=$1
  printf "\[\033[1;31m\][xx]\[\033[0m\] %s\n" "${MESSAGE}" >&2
}
