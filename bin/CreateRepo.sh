#!/bin/bash

DIR="$(dirname $0)"

JSONFILE="$1"
if [ ! -f "${JSONFILE}" ]
then
	echo "Gearbox: Can't find JSON file: ${JSONFILE}"
	exit
fi

${DIR}/CreateBuild.sh "${JSONFILE}"
${DIR}/CreateVersion.sh "${JSONFILE}"

cp TEMPLATE/README.md.tmpl .
${DIR}/JsonToConfig-Darwin -json "${JSONFILE}" -create README.md.tmpl 
