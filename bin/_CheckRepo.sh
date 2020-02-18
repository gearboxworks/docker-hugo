#!/bin/bash

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
		echo "	$(./bin/JsonToConfig-Darwin -json "${version}/gearbox.json" -template-string '{{ .Json.version }} - {{ .Json.organization }}/{{ .Json.name }}:{{ .Json.version }}')"
	done
	unset VERSIONS
fi

