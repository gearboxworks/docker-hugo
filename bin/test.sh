#!/bin/bash

DIR="$(dirname $0)"

echo "################################################################################"
. ${DIR}/_GetVersions.sh
if [ "${VERSIONS}" == "" ]
then
	echo "# Gearbox: Running ${0} failed"
	exit 1
fi
echo "# Gearbox: Running ${0} for versions: ${VERSIONS}"

for VERSION in ${VERSIONS}
do
	JSONFILE="${VERSION}/gearbox.json"
	if [ ! -f "${JSONFILE}" ]
	then
		echo "Gearbox: Can't find JSON file: ${JSONFILE}"
		exit
	fi

	${DIR}/_GetEnv.sh "${JSONFILE}"
	. "${VERSION}/.env"

	STATE="$(${DIR}/_CheckContainer.sh ${GB_CONTAINERVERSION})"
	case ${STATE} in
		'STARTED')
			;;
		'STOPPED')
			${DIR}/start.sh ${GB_VERSION}
			;;
		'MISSING')
			${DIR}/create.sh ${GB_VERSION}
			${DIR}/start.sh ${GB_VERSION}
			;;
		*)
			echo "# Gearbox[${GB_CONTAINERVERSION}]: Unknown state."
			;;
	esac

	STATE="$(${DIR}/_CheckContainer.sh ${GB_CONTAINERVERSION})"
	case ${STATE} in
		'STARTED')
			echo "# Gearbox[${GB_CONTAINERVERSION}]: Running unit-tests."
			PORT="$(docker port ${GB_CONTAINERVERSION} 22/tcp | sed 's/0.0.0.0://')"
			ssh -p ${PORT} gearbox@localhost /etc/gearbox/unit-tests/run.sh
			;;
		*)
			echo "# Gearbox[${GB_CONTAINERVERSION}]: Unknown state."
			;;
	esac
done

