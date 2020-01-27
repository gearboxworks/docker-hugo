#!/bin/sh

if [ "$1" == "interactive" ]
then
	shift
	ARG1=$1
	shift
	case $ARG1 in
		'build'|'gh-deploy'|'new')
			ARGS=""
			;;

		'server')
			echo "Gearbox: Warning - Can only serve from container."
			exit
			;;

		*)
			ARGS=""
			;;
	esac
else
	ARG1="server"
	ARGS="-a 0.0.0.0:1313"
fi

exec /usr/local/bin/hugo $ARG1 $ARGS "$@"
