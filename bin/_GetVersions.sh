#!/bin/bash

# WARNING: This file is SOURCED. Don't add in any "exit", otherwise your shell will exit.

getall() {
	VERSIONS="$(find * -maxdepth 1 -type f -name 'gearbox.json' | sed 's/\/gearbox.json//' | sort -rn)"
	VERSIONS="$(echo ${VERSIONS})"
	# Easily remove CR
}


################################################################################
DIR="$(dirname $0)"

GB_GITURL="$(git config --get remote.origin.url)"; export GB_GITURL
if [ "${GB_GITURL}" == "" ]
then
	GB_GITREPO=""; export GB_GITREPO
else
	GB_GITREPO="$(basename -s .git ${GB_GITURL})"; export GB_GITREPO
fi

if [ "${GB_GITREPO}" == "docker-template" ]
then
	echo "Cannot run this command from the docker-template repository."
	echo "IF THIS IS A COPY of that repo, then..."
	echo "	1. Remove the .git directory."
	echo "	2. Run the \"make init\" command."
	echo ""
	unset VERSIONS GB_GITURL GB_GITREPO

else
	if [ "$1" == "all" ]
	then
		getall
	else
		VERSIONS="$@"
	fi

	if [ "${VERSIONS}" == "" ]
	then
		echo "# Gearbox: ERROR - No versions specified."
		getall
		echo "# Gearbox: Versions available - ${VERSIONS}"
		echo "	all - All versions"
		for version in ${VERSIONS}
		do
			echo "	$("${DIR}/JsonToConfig-Darwin" -json "${version}/gearbox.json" -template-string '{{ .Json.version }} - {{ .Json.organization }}/{{ .Json.name }}:{{ .Json.version }}')"
		done
		unset VERSIONS
	fi
fi
