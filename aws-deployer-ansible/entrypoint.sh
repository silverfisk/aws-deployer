#!/bin/bash

case "$1" in
  *sh)
    exec "$@"
    exit 1
    ;;
esac
exec /usr/bin/assume "$@"
