#!/bin/bash

CONTAINER_NAME="$1"

EXISTS="$(docker container ls -q -a -f name="^${CONTAINER_NAME}")"
if [ "${EXISTS}" == "" ]
then
	# Not created.
	echo "MISSING"
	exit
fi

EXISTS="$(docker container ls -q -f name="^${CONTAINER_NAME}")"
if [ "${EXISTS}" == "" ]
then
	# Not created.
	echo "STOPPED"
	exit
fi

echo "STARTED"

