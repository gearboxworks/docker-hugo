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

	echo "# Gearbox[${GB_IMAGEMAJORVERSION}]: Inspect image."
	docker image inspect ${GB_IMAGEMAJORVERSION} 2>&1
	echo "# Gearbox[${GB_IMAGEVERSION}]: Inspect image."
	docker image inspect ${GB_IMAGEVERSION} 2>&1

	echo "# Gearbox[${GB_CONTAINERMAJORVERSION}]: Inspect container."
	docker container inspect name="^${GB_CONTAINERMAJORVERSION}" 2>&1
	echo "# Gearbox[${GB_CONTAINERVERSION}]: Inspect container."
	docker container inspect name="^${GB_CONTAINERVERSION}" 2>&1
done

