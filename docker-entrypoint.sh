#!/bin/bash
set -e

if [ "$1" = 'ragent' ]; then

	echo
	for f in /docker-entrypoint-init.d/*.sh; do
		echo "$0: running $f"; 
		/bin/bash "$f";
	done


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
	exec gosu usr1cv8 /opt/1C/v8.3/i386/ragent

fi

exec "$@"
