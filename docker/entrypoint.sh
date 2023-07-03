#!/bin/sh

set -e 

if [ "$1" = 'nautid' ]; then
    ./init.sh

    exec "$@" "--"
fi

exec "$@"