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

	if [ -f "${VERSION}/logs/${GB_NAME}.log" ]
	then
		echo "# Gearbox[${GB_IMAGEMAJORVERSION}]: Showing logs."
		script -dp "${VERSION}/logs/${GB_NAME}.log" | less -SinR
	else
		echo "# Gearbox[${GB_IMAGEMAJORVERSION}]: No logs."
	fi
done

