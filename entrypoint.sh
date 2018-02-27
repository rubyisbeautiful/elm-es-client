#!/bin/bash

set -e

cd "/usr/src/app" || exit 1

if [ ! -d "/usr/src/app/elm-stuff" ]; then
  npm install
  # cd tests || exit 1
  # elm-package install -y
  # cd .. || exit 1
fi

if [ -z "$1" ]; then
  exec elm-reactor -p "$ELM_ES_PORT" -a 0.0.0.0
else
  exec "$@"
fi
