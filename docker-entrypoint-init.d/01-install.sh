#!/bin/bash
set -e

if [[ -z "$ARCH1C" || -z "$RAGENT" ]]; then
    echo "ERROR: empty env ARCH1C or RAGENT"
    exit 1
fi

if [[ ! -f $RAGENT ]]; then

    DIST_1C=${DIST_1C:="/dist"}

    if [[ -d "$DIST_1C" ]]; then
        mkdir -p /tmp/dist
        find $DIST_1C -name \*.tar.gz -exec tar -zxvf {} -C /tmp/dist/ \;
        find $DIST_1C -name \*.deb -exec cp {} /tmp/dist/ \;
        DIST_1C=/tmp/dist
    fi

    if [[ -f "$DIST_1C" && ${DIST_1C: -7} == ".tar.gz" ]]; then
        mkdir -p /tmp/dist
        tar -zxvf $DIST_1C -C /tmp/dist
        DIST_1C=/tmp/dist
    fi

    install_1c_pkg ()
    {
        PKG_NAME=$1
        REQUIRED=$2
        PKG_FILE=`find $DIST_1C -type f -regex $DIST_1C/?1c-enterprise[0-9]+-${PKG_NAME}_[0-9]+\.[0-9]+\.[0-9]+-[0-9]+_$ARCH1C\.deb`
        if [[ -n "$PKG_FILE" ]]; then
            dpkg -i $PKG_FILE
        elif [[ "$REQUIRED" == "--required" ]]; then
            echo "Не найден пакет: $PKG_NAME"
            return 1
        fi
        return 0
    }

    install_1c_pkg common --required
    install_1c_pkg server --required
    install_1c_pkg ws --required

    rm -rf /tmp/*

fi