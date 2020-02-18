#!/bin/bash

JSONFILE="$1"
DIR="$(./bin/JsonToConfig-Darwin -json "${JSONFILE}" -template-string '{{ .Json.version }}')"
if [ ! -d "${DIR}" ]
then
	mkdir -p "${DIR}"
fi

cat <<EOF > "${DIR}/.env.tmpl"
GB_STATE='{{ .Json.state }}'; export GB_STATE
GB_ORGANIZATION='{{ .Json.organization }}'; export GB_ORGANIZATION
GB_NAME='{{ .Json.name }}'; export GB_NAME
GB_MAINTAINER='{{ .Json.maintainer }}'; export GB_MAINTAINER
GB_VERSION='{{ .Json.version }}'; export GB_VERSION
GB_MAJORVERSION='{{ .Json.majorversion }}'; export GB_MAJORVERSION
GB_LATEST='{{ .Json.latest }}'; export GB_LATEST
GB_CLASS='{{ .Json.class }}'; export GB_CLASS
GB_NETWORK='{{ .Json.network }}'; export GB_NETWORK

GB_PORTS='{{ range .Json.ports }}{{ . }} {{ end }}'; export GB_PORTS
GB_VOLUMES='{{ .Json.volumes }}'; export GB_VOLUMES
GB_RESTART='{{ .Json.restart }}'; export GB_RESTART
GB_ARGS='{{ .Json.args }}'; export GB_ARGS
GB_ENV='{{ .Json.env }}'; export GB_ENV

GB_BASE='{{ .Json.base }}'; export GB_BASE
GB_REF='{{ .Json.ref }}'; export GB_REF

GB_DOCKERFILE='{{ .Json.version }}/DockerfileRuntime'; export GB_DOCKERFILE
GB_JSONFILE='{{ .Json.version }}/gearbox.json'; export GB_JSONFILE
GB_JSON='{{ .JsonString }}'; export GB_JSON

GB_IMAGENAME='{{ .Json.organization }}/{{ .Json.name }}'; export GB_IMAGENAME
GB_IMAGEVERSION='{{ .Json.organization }}/{{ .Json.name }}:{{ .Json.version }}'; export GB_IMAGEVERSION
GB_IMAGEMAJORVERSION='{{ .Json.organization }}/{{ .Json.name }}:{{ .Json.majorversion }}'; export GB_IMAGEMAJORVERSION

GB_CONTAINERVERSION='{{ .Json.name }}-{{ .Json.version }}'; export GB_CONTAINERVERSION
GB_CONTAINERMAJORVERSION='{{ .Json.name }}-{{ .Json.majorversion }}'; export GB_CONTAINERMAJORVERSION

OS_TYPE="$(uname -s)"; export OS_TYPE

EOF

./bin/JsonToConfig-Darwin -json "${JSONFILE}" -create "${DIR}/.env.tmpl" 

