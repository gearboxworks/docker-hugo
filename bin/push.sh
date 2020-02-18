#!/bin/bash

DIR="$(dirname $0)"

echo "################################################################################"
. ${DIR}/_GetVersions.sh
if [ "${VERSIONS}" == "" ]
then
	echo "# Gearbox: Running ${0} failed"
	exit 1
fi
echo "# Gearbox: Running ${0} for repository containing versions: ${VERSIONS}"

"${DIR}/push-dockerhub.sh" ${VERSIONS}
"${DIR}/push-github.sh" ${VERSIONS}
