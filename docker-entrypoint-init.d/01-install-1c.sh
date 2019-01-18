#!/bin/bash
set -xue

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

if [[ -n "$UID_1C" ]]; then
    usermod -u $UID_1C usr1cv8
fi

if [[ -n "$GID_1C" ]]; then
    groupmod -g $GID_1C grp1cv8
fi

mkdir -p ${DIR_1C_USER}/{sync,tmp,web}
chmod 775 ${DIR_1C_USER}
chown -R usr1cv8:grp1cv8 ${DIR_1C_USER}

DIR_1C_WEB=${DIR_1C_WEB:=${DIR_1C_USER}/web}
APACHE_CONFDIR=${APACHE_CONFDIR:=/etc/apache2}
WEB_CONFIG_1C=${APACHE_CONFDIR}/conf-enabled/99-1c-db.conf

if [[ ! -f ${WEB_CONFIG_1C} ]]; then
    echo "IncludeOptional ${DIR_1C_WEB}/*/.conf" > ${WEB_CONFIG_1C}
fi

find ${DIR_1C_WEB} -type d -exec chmod 0755 {} \;
find ${DIR_1C_WEB}/*/www -type f -exec chmod 0644 {} \;
