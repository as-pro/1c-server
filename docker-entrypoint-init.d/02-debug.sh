#!/bin/bash
set -e

if [[ -f /etc/init.d/srv1cv83 ]]; then

    SED_CMD=""

    if [[ "$DEBUG" == "1" || "$DEBUG" == "true"  || "$DEBUG" == "on" ]]; then
        DEBUG=1
        echo "Enable 1c debug"
        SED_CMD="$SED_CMD s/\s*#\s*SRV1CV8_DEBUG\s*=.*/SRV1CV8_DEBUG=1/g; "
    else
        echo "Disable 1c debug"
        SED_CMD="$SED_CMD s/\s*SRV1CV8_DEBUG=1\s*/#SRV1CV8_DEBUG=/g; "
    fi

    if [[ "$DEBUG" == "1" && "$DEBUG_MODE" == "http" ]]; then
        echo "Enable 1c http debug"
        SED_CMD="$SED_CMD s/\(cmdline=\"\\\$cmdline\s\+-debug\)\(\s*\"\)/\1 -http\2/g; "
    else
        echo "Disable 1c http debug"
        SED_CMD="$SED_CMD s/\(cmdline=\"\\\$cmdline\s\+-debug\)\s\+-http\(\s*\"\)/\1\2/g; "
    fi

    echo $SED_CMD
    sed -i -e "$SED_CMD" /etc/init.d/srv1cv83

fi