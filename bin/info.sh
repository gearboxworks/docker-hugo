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

	echo "# Gearbox[${GB_IMAGEMAJORVERSION}]: List image."
	docker image ls ${GB_IMAGEMAJORVERSION}
	echo "# Gearbox[${GB_IMAGEVERSION}]: List image."
	docker image ls ${GB_IMAGEVERSION}

	echo "# Gearbox[${GB_CONTAINERMAJORVERSION}]: List container."
	docker container ls -f name="^${GB_CONTAINERMAJORVERSION}"
	echo "# Gearbox[${GB_CONTAINERVERSION}]: List container."
	docker container ls -f name="^${GB_CONTAINERVERSION}"
done

