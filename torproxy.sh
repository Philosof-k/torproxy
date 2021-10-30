#!/usr/bin/env bash

set -o nounset                              # Treat unset variables as an error


chown -Rh tor. /etc/tor /var/lib/tor /var/log/tor 2>&1 |
            grep -iv 'Read-only' || :

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 13
elif ps -ef | egrep -v 'grep|torproxy.sh' | grep -q tor; then
    echo "Service already running, please restart container to apply changes"
else
    [[ -e /srv/tor/hidden_service/hostname ]] && {
        echo -en "\nHidden service hostname: "
        cat /srv/tor/hidden_service/hostname; echo; }
    /usr/sbin/privoxy --user privoxy /etc/privoxy/config
    exec /usr/bin/tor
fi