#!/bin/bash
set -e

if [[ -f /etc/init.d/srv1cv83 ]]; then

    if [[ "$DEBUG" == "1" || "$DEBUG" == "true"  || "$DEBUG" == "on" ]]; then
        DEBUG=1
        echo "Enable 1c debug"
        RAGENT="$RAGENT -debug"
    fi

    if [[ "$DEBUG" == "1" && "$DEBUG_MODE" == "http" ]]; then
        echo "Enable 1c http debug"
        RAGENT="$RAGENT -http"
    fi

fi