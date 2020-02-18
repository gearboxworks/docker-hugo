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
			echo "# Gearbox[${GB_CONTAINERVERSION}]: Removing container, (present and running)."
			docker container rm -f ${GB_CONTAINERVERSION}
			;;
		'STOPPED')
			echo "# Gearbox[${GB_CONTAINERVERSION}]: Removing container, (present and shutdown)."
			docker container rm -f ${GB_CONTAINERVERSION}
			;;
		'MISSING')
			echo "# Gearbox[${GB_CONTAINERVERSION}]: Container already removed."
			;;
		*)
			echo "# Gearbox[${GB_CONTAINERVERSION}]: Unknown state."
			;;
	esac
done

