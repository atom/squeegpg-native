#!/usr/bin/env bash
#
# Initialize the current shell with chruby on CircleCI.

if [ -f /usr/local/share/chruby/chruby.sh ]; then
  source /usr/local/share/chruby/chruby.sh
  chruby 2.4.2
fi
