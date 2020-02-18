#!/bin/bash

DIR="$(dirname $0)"
CMD="$1"
VERSION="$2"


help() {
cat<<EOF

$(basename $0)
	Updates the docker-template GitHub repository with either a new or updated release.

$(basename $0) create [version] - Creates a new release on GitHub.
$(basename $0) update [version] - Updates an existing release on GitHub.

if [version] isn't specified, then...
- Prompt the user for a new version.
- Do nothing.
EOF
}


################################################################################
GB_GITURL="$(git config --get remote.origin.url)"; export GB_GITURL
if [ "${GB_GITURL}" == "" ]
then
	GB_GITREPO=""; export GB_GITREPO
else
	GB_GITREPO="$(basename -s .git ${GB_GITURL})"; export GB_GITREPO
fi

if [ "${GB_GITREPO}" != "docker-template" ]
then
	echo "################################### WARNING ###################################"
	echo "# This command can only be run from the docker-template GitHub repository."
	echo "# Only gearboxworks staff use this command to update the docker-template repo."
	echo "# Check out the README file on how to use this repo."
	echo "################################### WARNING ###################################"
	exit 1
fi

################################################################################
if [ "${CMD}" == "" ]
then
	echo "# Gearbox[${GB_GITREPO}]: Doing nothing."
	help
	exit 1
fi

if [ "${VERSION}" == "" ]
then
	echo "# Gearbox[${GB_GITREPO}]: No release version specified."
	echo -n "Enter a release version: "
	read VERSION

	if [ "${VERSION}" == "" ]
	then
		echo "# Gearbox[${GB_GITREPO}]: No version entered? OK doing nothing."
		exit 1
	fi
fi


echo "################################################################################"
echo "# Gearbox[${GB_GITREPO}]: Pushing repo to GitHub."
git commit -a -m "Latest push" && git push


echo "# Gearbox[${GB_GITREPO}]: Creating release on GitHub."
if [ "${GB_GITREPO}" == "" ]
then
	echo "# Gearbox[${GB_GITREPO}]: GB_GITREPO isn't set... Strange..."
	echo "# Gearbox[${GB_GITREPO}]: Abandoning GitHub release changes."
	exit 1
fi

if [ "${GITHUB_USER}" == "" ]
then
	echo "# Gearbox[${GB_GITREPO}]: GITHUB_USER needs to be set to ${CMD} a release."
	echo "# Gearbox[${GB_GITREPO}]: Abandoning GitHub release changes."
	exit 1
fi

if [ "${GITHUB_TOKEN}" == "" ]
then
	echo "# Gearbox[${GB_GITREPO}]: GITHUB_TOKEN needs to be set to ${CMD} a release."
	echo "# Gearbox[${GB_GITREPO}]: Abandoning GitHub release changes."
	exit 1
fi


check() {
	echo "# Gearbox[${GB_GITREPO}]: Checking if release v${VERSION} exists."
	${DIR}/github-release info \
		-u gearboxworks \
		-r "${GB_GITREPO}" \
		-t "${VERSION}" >& /dev/null
	RETURN="$?"
	# 0 - Exists.
	# 1 - Doesn't exist.
}

create() {
	echo "# Gearbox[${GB_GITREPO}]: Creating release v${VERSION} on GitHub."
	${DIR}/github-release release \
		--user "gearboxworks" \
		--repo "${GB_GITREPO}" \
		--tag "${VERSION}" \
		--name "Release ${VERSION}"
}

upload() {
	FILES="Makefile TEMPLATE bin"
	echo "# Gearbox[${GB_GITREPO}]: Creating tarball release from files: ${FILES}"
	tar zcf docker-template.tgz ${FILES}

	echo "# Gearbox[${GB_GITREPO}]: Uploading tarball release v${VERSION} to GitHub."
	${DIR}/github-release upload \
		--user "gearboxworks" \
		--repo "${GB_GITREPO}" \
		--tag "${VERSION}" \
		--name "docker-template.tgz" \
		--label "docker-template.tgz" \
		-R \
		-f docker-template.tgz

	rm -f docker-template.tgz
}


export RETURN
case "${CMD}" in
	'create')
		check
		if [ "${RETURN}" == "0" ]
		then
			echo "# Gearbox[${GB_GITREPO}]: Release v${VERSION} already exists. Abandoning create."
			exit 1
		fi

		create

		upload

		echo "# Gearbox[${GB_GITREPO}]: Release v${VERSION} OK."
		;;

	'update')
		check
		if [ "${RETURN}" != "0" ]
		then
			echo "# Gearbox[${GB_GITREPO}]: No release v${VERSION} found."
			exit 1
		fi

		upload

		echo "# Gearbox[${GB_GITREPO}]: Release v${VERSION} OK."
		;;

	'delete')
		;;
esac

