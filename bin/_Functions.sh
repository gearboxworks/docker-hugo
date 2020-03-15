#!/bin/bash

# WARNING: This file is SOURCED. Don't add in any "exit", otherwise your shell will exit.
export ARCH GB_BINFILE GB_BINDIR GB_BASEDIR GB_JSONFILE GB_VERSIONS GB_VERSION GITBIN GB_GITURL GB_GITREPO

ARCH="$(uname -s)"
case ${ARCH} in
	'Linux')
		LOG_ARGS='-t 10'
		;;
	*)
		LOG_ARGS='-r -t 10'
		;;
esac

GB_BINFILE="$(./bin/JsonToConfig -json-string '{}' -template-string '{{ .ExecName }}')"
GB_BINDIR="$(./bin/JsonToConfig -json-string '{}' -template-string '{{ .DirPath }}')"
GB_BASEDIR="$(dirname "$GB_BINDIR")"
GB_JSONFILE="${GB_BASEDIR}/gearbox.json"

if [ -f "${GB_JSONFILE}" ]
then
	GB_VERSIONS="$(${GB_BINFILE} -json ${GB_JSONFILE} -template-string '{{ range $version, $value := .Json.versions }}{{ $version }} {{ end }}')"
	GB_VERSIONS="$(echo ${GB_VERSIONS})"	# Easily remove CR

	GB_IMAGENAME="$(${GB_BINFILE} -json ${GB_JSONFILE} -template-string '{{ .Json.organization }}/{{ .Json.name }}')"

	GB_NAME="$(${GB_BINFILE} -json ${GB_JSONFILE} -template-string '{{ .Json.name }}')"
fi

GITBIN="$(which git)"
GB_GITURL="$(${GITBIN} config --get remote.origin.url)"
if [ "${GB_GITURL}" == "" ]
then
	GB_GITREPO=""
else
	GB_GITREPO="$(basename -s .git ${GB_GITURL})"
fi

. ${GB_BINDIR}/_Colors.sh


################################################################################
_getVersions() {
	if [ ! -f "${GB_JSONFILE}" ]
	then
		c_err "Can't find JSON file: ${GB_JSONFILE}"
		return 0
	fi

	if [ "${GB_VERSIONS}" == "" ]
	then
		c_err "No versions found"
		return 0
	fi

	if [ "${GB_GITREPO}" == "docker-template" ]
	then
		c_warn "Cannot run this command from the docker-template repository."
		c_warn "IF THIS IS A COPY of that repo, then..."
		c_warn "	1. Remove the .git directory."
		c_warn "	2. Run the \"make init\" command."
		c_warn ""
		unset GB_VERSIONS GB_GITURL GB_GITREPO

	else
		case $1 in
			'all')
				;;
			'')
				c_warn "No versions specified."
				c_info "Versions available:"
				_listVersions
				unset GB_VERSIONS
				return 0
				;;
			*)
				GB_VERSIONS="$@"
				;;
		esac
	fi

	return 1
}


################################################################################
_listVersions() {
	echo "	all - All versions"
	${GB_BINFILE} -json ${GB_JSONFILE} -template-string '{{ range $version, $value := .Json.versions }}\t{{ $version }} - {{ $.Json.organization }}/{{ $.Json.name }}:{{ $version }}\n{{ end }}'
	echo ""
}


################################################################################
gb_getenv() {
	VERSION_DIR="$1"
	if [ -f "${VERSION_DIR}/.env.tmpl" ]
	then
		# DIR="$(./bin/JsonToConfig-${ARCH} -json "${GB_JSONFILE}" -template-string '{{ .Json.version }}')"
		${GB_BINFILE} -json "${GB_JSONFILE}" -template "${VERSION_DIR}/.env.tmpl" -out "${VERSION_DIR}/.env"
	fi

	. "${VERSION_DIR}/.env"
}


################################################################################
gb_checkImage() {
	STATE="$(docker image ls -q "$1")"
	if [ "${STATE}" == "" ]
	then
		# Not created.
		STATE="MISSING"
	else
		STATE="PRESENT"
	fi
}


################################################################################
gb_checkContainer() {
	STATE="$(docker container ls -q -a -f name="^$1")"
	if [ "${STATE}" == "" ]
	then
		# Not created.
		STATE="MISSING"
		return
	fi

	STATE="$(docker container ls -q -f name="^$1")"
	if [ "${STATE}" == "" ]
	then
		# Not created.
		STATE="STOPPED"
		return
	fi

	STATE="STARTED"
}


################################################################################
gb_checknetwork() {
	STATE="$(docker network ls -qf "name=gearboxnet")"
	if [ "${STATE}" == "" ]
	then
		# Create network
		echo "Creating network"
		docker network create --subnet 172.42.0.0/24 gearboxnet
	fi
}


################################################################################
gb_init() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "Initializing repo."

	gb_create-build ${GB_JSONFILE}
	gb_create-version ${GB_JSONFILE}
	${DIR}/JsonToConfig-$(uname -s) -json "${GB_JSONFILE}" -template TEMPLATE/README.md.tmpl -out README.md

	return 0
}


################################################################################
gb_create-build() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "Creating build directory."

	if [ -d build ]
	then
		p_warn "${FUNCNAME[0]}" "Directory \"build\" already exists."
		return 0
	fi

	cp -i TEMPLATE/build.sh.tmpl .
	${GB_BINFILE} -json ${GB_JSONFILE} -create build.sh.tmpl -shell
	rm -f build.sh.tmpl build.sh

	${GB_BINFILE} -template ./TEMPLATE/README.md.tmpl -json ${GB_JSONFILE} -out README.md

	return 0
}


################################################################################
gb_create-version() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "Creating version directory for versions: ${GB_VERSIONS}"


	${GB_BINFILE} -template ./TEMPLATE/README.md.tmpl -json ${GB_JSONFILE} -out README.md

	for GB_VERSION in ${GB_VERSIONS}
	do
		if [ -d ${GB_VERSION} ]
		then
			p_warn "${FUNCNAME[0]}" "Directory \"${GB_VERSION}\" already exists."
		else
			p_info "${FUNCNAME[0]}" "Creating version directory \"${GB_VERSION}\"."
			cp -i TEMPLATE/version.sh.tmpl .
			${GB_BINFILE} -json ${GB_JSONFILE} -create version.sh.tmpl -shell
			rm -f version.sh.tmpl version.sh
		fi
	done

	return 0
}


################################################################################
gb_clean() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Cleaning up for versions: ${GB_VERSIONS}"


	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}


		p_info "${GB_IMAGEVERSION}" "Removing logs."
		rm -f ${GB_VERSION}/logs/*.log


		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				p_info "${GB_CONTAINERVERSION}" "Removing container, (present and running)."
				docker container rm -f ${GB_CONTAINERVERSION}
				;;
			'STOPPED')
				p_info "${GB_CONTAINERVERSION}" "Removing container, (present and shutdown)."
				docker container rm -f ${GB_CONTAINERVERSION}
				;;
			'MISSING')
				p_warn "${GB_CONTAINERVERSION}" "Container already removed."
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac


		gb_checkImage ${GB_IMAGEMAJORVERSION}
		case ${STATE} in
			'PRESENT')
				p_info "${GB_IMAGEMAJORVERSION}" "Removing image."
				docker image rm -f ${GB_IMAGEMAJORVERSION}
				;;
			*)
				p_warn "${GB_IMAGEMAJORVERSION}" "Image already removed."
				;;
		esac


		gb_checkImage ${GB_IMAGEVERSION}
		case ${STATE} in
			'PRESENT')
				p_info "${GB_IMAGEVERSION}" "Removing image."
				docker image rm -f ${GB_IMAGEVERSION}
				;;
			*)
				p_warn "${GB_IMAGEVERSION}" "Image already removed."
				;;
		esac
	done

	return 0
}


################################################################################
gb_build() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Building image for versions: ${GB_VERSIONS}"


	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		# LOGFILE="${GB_VERSION}/logs/$(date +'%Y%m%d-%H%M%S').log"
		LOGFILE="${GB_VERSION}/logs/build.log"

		if [ "${GB_REF}" == "base" ]
		then
			p_info "${GB_IMAGENAME}:${GB_VERSION}" "This is a base container."

		elif [ "${GB_REF}" != "" ]
		then
			p_info "${GB_IMAGENAME}:${GB_VERSION}" "Pull ref container."
			docker pull "${GB_REF}"
			p_info "${GB_IMAGENAME}:${GB_VERSION}" "Query ref container."
			GEARBOX_ENTRYPOINT="$(docker inspect --format '{{ with .ContainerConfig.Entrypoint}} {{ index . 0 }}{{ end }}' "${GB_REF}")"
			export GEARBOX_ENTRYPOINT
			GEARBOX_ENTRYPOINT_ARGS="$(docker inspect --format '{{ join .ContainerConfig.Entrypoint " " }}' "${GB_REF}")"
			export GEARBOX_ENTRYPOINT_ARGS
		fi

		p_info "${GB_IMAGENAME}:${GB_VERSION}" "Building container."
		if [ "${GITHUB_ACTIONS}" == "" ]
		then
			script ${LOG_ARGS} ${LOGFILE} \
				docker build -t ${GB_IMAGENAME}:${GB_VERSION} -f ${GB_DOCKERFILE} --build-arg GEARBOX_ENTRYPOINT --build-arg GEARBOX_ENTRYPOINT_ARGS .
			p_info "${GB_IMAGENAME}:${GB_VERSION}" "Log file saved to \"${LOGFILE}\""
		fi

		docker build -t ${GB_IMAGENAME}:${GB_VERSION} -f ${GB_DOCKERFILE} --build-arg GEARBOX_ENTRYPOINT --build-arg GEARBOX_ENTRYPOINT_ARGS .

		if [ "${GB_MAJORVERSION}" != "" ]
		then
			docker tag ${GB_IMAGENAME}:${GB_VERSION} ${GB_IMAGENAME}:${GB_MAJORVERSION}
		fi
	done

	return 0
}


################################################################################
gb_create() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Creating container for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				p_info "${GB_IMAGEVERSION}" "Container already exists and is started."
				;;
			'STOPPED')
				p_info "${GB_IMAGEVERSION}" "Container already exists and is stopped."
				;;
			'MISSING')
				p_info "${GB_IMAGEVERSION}" "Creating container."
				docker create --name ${GB_CONTAINERVERSION} ${GB_NETWORK} -P ${GB_VOLUMES} ${GB_IMAGEVERSION}
				;;
			*)
				p_err "${GB_IMAGEVERSION}" "Unknown state."
				return 1
				;;
		esac
	done

	return 0
}


################################################################################
gb_info() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Image and container info for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		p_info "${GB_IMAGEMAJORVERSION}" "List image."
		docker image ls ${GB_IMAGEMAJORVERSION}
		p_info "${GB_IMAGEVERSION}" "List image."
		docker image ls ${GB_IMAGEVERSION}

		echo "# Gearbox[${GB_CONTAINERMAJORVERSION}]: List container."
		docker container ls -f name="^${GB_CONTAINERMAJORVERSION}"
		p_info "${GB_CONTAINERVERSION}" "List container."
		docker container ls -f name="^${GB_CONTAINERVERSION}"
	done

	return 0
}


################################################################################
gb_inspect() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Inspecting image and container for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		p_info "${GB_IMAGEMAJORVERSION}" "Inspect image."
		docker image inspect ${GB_IMAGEMAJORVERSION} 2>&1
		p_info "${GB_IMAGEVERSION}" "Inspect image."
		docker image inspect ${GB_IMAGEVERSION} 2>&1

		echo "# Gearbox[${GB_CONTAINERMAJORVERSION}]: Inspect container."
		docker container inspect name="^${GB_CONTAINERMAJORVERSION}" 2>&1
		p_info "${GB_CONTAINERVERSION}" "Inspect container."
		docker container inspect name="^${GB_CONTAINERVERSION}" 2>&1
	done

	return 0
}


################################################################################
gb_list() {
	if _getVersions $@
	then
		return 1
	fi

	p_ok "${FUNCNAME[0]}" "#### Listing images for ${GB_IMAGENAME}"
	docker image ls "${GB_IMAGENAME}:*"

	p_ok "${FUNCNAME[0]}" "#### Listing containers for ${GB_NAME}"
	docker container ls -a -s -f name="^${GB_NAME}-"

	return 0
}


################################################################################
gb_logs() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Showing build logs for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		if [ -f "${GB_VERSION}/logs/${GB_NAME}.log" ]
		then
			p_info "${GB_IMAGEMAJORVERSION}" "Showing logs."
			script -dp "${GB_VERSION}/logs/${GB_NAME}.log" | less -SinR
		else
			p_warn "${GB_IMAGEMAJORVERSION}" "No logs."
		fi
	done

	return 0
}


################################################################################
gb_ports() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Showing ports for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				p_info "${GB_CONTAINERVERSION}" "Showing exposed container ports."
				docker port ${GB_CONTAINERVERSION}
				;;
			'STOPPED')
				p_info "${GB_CONTAINERVERSION}" "Container needs to be started."
				;;
			'MISSING')
				p_info "${GB_CONTAINERVERSION}" "Need to create container first."
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac
	done

	return 0
}


################################################################################
gb_dockerhub() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Pushing to DockerHub for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		p_info "${GB_IMAGEVERSION}" "Pushing image to DockerHub."
		docker push ${GB_IMAGEVERSION}
		p_info "${GB_IMAGEMAJORVERSION}" "Pushing image to DockerHub."
		docker push ${GB_IMAGEMAJORVERSION}
	done

	return 0
}


################################################################################
gb_github() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Pushing to GitHub for repo."

	if [ "${GITHUB_ACTIONS}" != "" ]
	then
		echo "# Gearbox[${GB_GITREPO}]: Running from GitHub action - ignoring."
		return 1
	fi

	echo "# Gearbox[${GB_GITREPO}]: Pushing repo to GitHub."
	git commit -a -m "Latest push" && git push

	return 0
}


################################################################################
gb_push() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Pushing to GitHub and DockerHub for versions: ${GB_VERSIONS}"

	gb_dockerhub ${GB_VERSIONS}
	gb_github ${GB_VERSIONS}
	return 0
}


################################################################################
gb_release() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Releasing for versions: ${GB_VERSIONS}"

	gb_clean ${GB_VERSIONS} && \
		gb_build ${GB_VERSIONS} && \
		gb_test ${GB_VERSIONS}

	return 0
}


################################################################################
gb_rm() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Removing container for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				p_info "${GB_CONTAINERVERSION}" "Removing container, (present and running)."
				docker container rm -f ${GB_CONTAINERVERSION}
				;;
			'STOPPED')
				p_info "${GB_CONTAINERVERSION}" "Removing container, (present and shutdown)."
				docker container rm -f ${GB_CONTAINERVERSION}
				;;
			'MISSING')
				p_warn "${GB_CONTAINERVERSION}" "Container already removed."
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac
	done

	return 0
}


################################################################################
gb_shell() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Running shell for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				;;
			'STOPPED')
				gb_start ${GB_VERSION}
				;;
			'MISSING')
				gb_create ${GB_VERSION}
				gb_start ${GB_VERSION}
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				p_info "${GB_CONTAINERVERSION}" "Entering container."
				docker exec -i -t ${GB_CONTAINERVERSION} /bin/bash -l
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac
	done

	return 0
}


################################################################################
gb_ssh() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Running SSH for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				;;
			'STOPPED')
				gb_start ${GB_VERSION}
				;;
			'MISSING')
				gb_create ${GB_VERSION}
				gb_start ${GB_VERSION}
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				SSHPASS="$(which sshpass)"
				if [ "${SSHPASS}" != "" ]
				then
					SSHPASS="${SSHPASS} -pbox"
				fi

				p_info "${GB_CONTAINERVERSION}" "SSH into container."
				PORT="$(docker port ${GB_CONTAINERVERSION} 22/tcp | sed 's/0.0.0.0://')"

				${SSHPASS} ssh -p ${PORT} -o StrictHostKeyChecking=no gearbox@localhost
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac
	done

	return 0
}


################################################################################
gb_start() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "#### Starting container for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		p_info "${GB_CONTAINERVERSION}" "Checking network."
		gb_checknetwork

		p_info "${GB_CONTAINERVERSION}" "Starting container."
		docker start ${GB_CONTAINERVERSION}
	done

	return 0
}


################################################################################
gb_stop() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "Stopping container for versions: ${GB_VERSIONS}"

	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		p_info "${GB_CONTAINERVERSION}" "Stopping container."
		docker stop ${GB_CONTAINERVERSION}
	done

	return 0
}


################################################################################
gb_test() {
	if _getVersions $@
	then
		return 1
	fi
	p_ok "${FUNCNAME[0]}" "Testing container for versions: ${GB_VERSIONS}"

	ALL_FAILED=""
	for GB_VERSION in ${GB_VERSIONS}
	do
		gb_getenv ${GB_VERSION}

		gb_checkContainer ${GB_CONTAINERVERSION}
		case ${STATE} in
			'STARTED')
				;;
			'STOPPED')
				gb_start ${GB_VERSION}
				;;
			'MISSING')
				gb_create ${GB_VERSION}
				gb_start ${GB_VERSION}
				;;
			*)
				p_err "${GB_CONTAINERVERSION}" "Unknown state."
				return 1
				;;
		esac


		for RETRY in 1 2 3 4 5 6 7 8
		do
			sleep 1
			FAILED=""

			gb_checkContainer ${GB_CONTAINERVERSION}
			case ${STATE} in
				'STARTED')
					SSHPASS="$(which sshpass)"
					if [ "${SSHPASS}" != "" ]
					then
						SSHPASS="${SSHPASS} -pbox"
					fi

					p_info "${GB_CONTAINERVERSION}" "Running unit-tests."
					PORT="$(docker port ${GB_CONTAINERVERSION} 22/tcp | sed 's/0.0.0.0://')"

					# LOGFILE="${GB_VERSION}/logs/$(date +'%Y%m%d-%H%M%S').log"
					LOGFILE="${GB_VERSION}/logs/test.log"

					#if [ "${GITHUB_ACTIONS}" == "" ]
					#then
					#	script ${LOG_ARGS} ${LOGFILE}
					#fi

					if ssh -p ${PORT} -o StrictHostKeyChecking=no gearbox@localhost /etc/gearbox/unit-tests/run.sh 2>&1 | tee ${LOGFILE}
					then
						FAILED=""
						break
					else
						FAILED="Y"
						p_warn "${GB_CONTAINERVERSION}" "SSH failed - Retry count ${RETRY}."
					fi
					;;
				*)
					p_err "${GB_CONTAINERVERSION}" "Unknown state."
					FAILED="Y"
					;;
			esac
		done

		if [ "${FAILED}" != "" ]
		then
			FAILED_ALL="Y"
		fi
	done

	if [ "${FAILED_ALL}" == "" ]
	then
		return 0
	else
		p_err "${FUNCNAME[0]}" "Testing FAILED for versions: ${GB_VERSIONS}"
		return 1
	fi
}


