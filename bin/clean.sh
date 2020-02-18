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

	${DIR}/rm.sh "${VERSION}"

	echo "# Gearbox[${GB_IMAGEMAJORVERSION}]: Removing image."
	docker image rm -f ${GB_IMAGEMAJORVERSION}

	echo "# Gearbox[${GB_IMAGEVERSION}]: Removing image."
	docker image rm -f ${GB_IMAGEVERSION}

	echo "# Gearbox[${GB_IMAGEVERSION}]: Removing logs."
	rm -f "${GB_VERSION}/logs/*.log"
done

