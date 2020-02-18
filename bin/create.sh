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
			echo "# Gearbox[${GB_IMAGEVERSION}]: Container already exists and is started."
			;;
		'STOPPED')
			echo "# Gearbox[${GB_IMAGEVERSION}]: Container already exists and is stopped."
			;;
		'MISSING')
			echo "# Gearbox[${GB_IMAGEVERSION}]: Creating container."
			docker create --name ${GB_CONTAINERVERSION} ${GB_NETWORK} -P ${GB_VOLUMES} ${GB_IMAGEVERSION}
			;;
		*)
			echo "# Gearbox[${GB_IMAGEVERSION}]: Unknown state."
			;;
	esac
done

