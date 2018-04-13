#!/bin/bash

set -xe

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- ragent "$@"
fi

if [ "$1" = 'ragent' ]; then

    if [[ -z "$ARCH1C" || ( "$ARCH1C" != "i386" && "$ARCH1C" != "amd64" ) ]]; then
        echo "ERROR: env ARCH1C can only be 'i386' or 'amd64'"
        exit 1
    fi

    echo
    for f in /docker-entrypoint-init.d/*.sh; do
        echo "$0: running $f"; 
        /bin/bash "$f";
    done

    if [[ ! -f $RAGENT ]]; then
        echo "Не найден $RAGENT"
        exit 1
    fi

    if [[ -n "$UID_1C" ]]; then
        usermod -u $UID_1C usr1cv8
    fi

    if [[ -n "$GID_1C" ]]; then
        groupmod -g $GID_1C grp1cv8
    fi

    mkdir -p /home/usr1cv8/{sync,tmp}
    chmod 766 /home/usr1cv8
    chown -R usr1cv8:grp1cv8 /home/usr1cv8

    echo "run agent"
    exec gosu usr1cv8 $RAGENT

fi

exec "$@"
