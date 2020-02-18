#!/bin/bash

DIR="$(dirname $0)"

echo "################################################################################"
. ${DIR}/_GetVersions.sh
if [ "${VERSIONS}" == "" ]
then
	echo "# Gearbox: Running ${0} failed"
	exit 1
fi
echo "# Gearbox: Running ${0} for repo."

echo "# Gearbox[${GB_GITREPO}]: Pushing repo to GitHub."
git commit -a -m "Latest push" && git push

