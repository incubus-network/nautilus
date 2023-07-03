#!/bin/sh

set -e 

if [ "$1" = 'fury' ]; then
    ./init.sh

    exec "$@" "--"
fi

exec "$@"