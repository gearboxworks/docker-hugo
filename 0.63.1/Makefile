#
# Standard version level Makefile used to build a Docker container for Gearbox - https://github.com/gearboxworks/gearbox/
#

.ONESHELL:


# Determine whether we use "nodeJS" or "JQ".
JSONCMD := $(shell jq -r '.organization' ./gearbox.json)
ifneq ($(JSONCMD),)
define GetFromPkg
$(shell jq -r ".$(1)" ./gearbox.json)
endef

define rawJSON
$(shell jq -Mc -r '' ./gearbox.json)
endef

else
JSONCMD := $(shell node -p "require('./gearbox.json').organization")
ifneq ($(JSONCMD),)
define GetFromPkg
$(shell node -p "require('./gearbox.json').$(1)")
endef

define rawJSON
$(shell node -p "require('./gearbox.json')")
endef

else
$(shell )

endif
endif

define osSystem
$(shell uname)
endef

ifeq ($(osSystem),Linux)
LOG_ARGS	:= -t 10
else
LOG_ARGS	:= -r -t 10
endif

################################################################################
# Set global variables from container file.
ORGANIZATION	:= $(call GetFromPkg,organization)
NAME		:= $(call GetFromPkg,name)
VERSION		:= $(call GetFromPkg,version)
MAJORVERSION	:= $(call GetFromPkg,majorversion)
LATEST		:= $(call GetFromPkg,latest)
CLASS		:= $(call GetFromPkg,class)
NETWORK		:= $(call GetFromPkg,network)
PORTS		:= $(call GetFromPkg,ports)
VOLUMES		:= $(call GetFromPkg,volumes)
RESTART		:= $(call GetFromPkg,restart)
ARGS		:= $(call GetFromPkg,args)
STATE		:= $(call GetFromPkg,state)
ENV		:= $(call GetFromPkg,env)


# The critical bit. Determines what Dockerfile to build against.
ifeq ($(BUILD_TYPE),base)
SKIP		:= yes
DOCKERFILE	:= DockerfileBase
BUILD_ARGS	:= --build-arg BUILD_TYPE="$(BUILD_TYPE)" --squash
NAME		:= $(NAME)-$(BUILD_TYPE)

else
SKIP		:= no
DOCKERFILE	:= DockerfileRuntime
BUILD_ARGS	:= 
NAME		:= $(NAME)
endif


IMAGE_NAME	?= $(ORGANIZATION)/$(NAME)
CONTAINER_NAME	?= $(NAME)-$(VERSION)
CONTAINER_JSON	?= '$(call rawJSON)'


# LOGFILE := $(NAME)-$(shell date +'%Y%m%d-%H%M%S').log
LOGFILE := $(NAME).log


.PHONY: build push release clean list log inspect test create shell run start stop rm

################################################################################
# Image related commands.
default: all

all:
	@echo "clean		- Clean runtime container image."
	@echo "build		- Generate runtime container image."
	@echo "test		- Execute container unit tests."
	@echo "push		- Push runtime container image to DockerHub & GitHub."
	@echo ""
	@echo "release		- Do all of the above."
	@echo ""
	@echo "info		- Generate info from runtime container image."
	@echo "log		- Show log from last build."
	@echo "readme		- Show README.md."
	@echo ""
	@echo "Process:"
	@echo "	make clean"
	@echo "	make build"
	@echo "	make test"

all-multi:
	@echo "clean            - Clean base & final container image."
	@echo "build            - Build base & final container image."
	@echo "test             - Execute base & final container unit tests."
	@echo "push             - Push base & final container image to DockerHub & GitHub."
	@echo ""
	@echo "clean-base       - Clean base container image, [DockerfileBase]."
	@echo "build-base       - Build base container image, [DockerfileBase]."
	@echo "test-base        - Execute base container unit tests, [DockerfileBase]."
	@echo "push-base        - Push base container image to DockerHub & GitHub, [DockerfileBase]."
	@echo ""
	@echo "clean-final      - Clean final container image, [DockerfileFinal]."
	@echo "build-final      - Build final container image from base container image, [DockerfileFinal]."
	@echo "test-final       - Execute final container unit tests, [DockerfileFinal]."
	@echo "push-final       - Push final container image to DockerHub & GitHub, [DockerfileFinal]."
	@echo ""
	@echo "build-full       - Generate runtime container image without base reference, [DockerfileRuntime]."
	@echo ""
	@echo "info-base        - Generate PHP info from base container image."
	@echo "info             - Generate PHP info from final container image."
	@echo ""
	@echo "Process:"
	@echo " make clean-base"
	@echo " make build-base"
	@echo " make clean"
	@echo " make build"


define check_config
	@if [ "$(SKIP)" == "yes" ]; then echo "SKIP = yes"; exit 0; fi
endef
# $(call check_config)

check-config:
ifeq ($(SKIP),yes)
	@# Used to skip images without error.
	@exit 0
endif
ifeq ($(STATE),not_supported)
	@echo "Gearbox: Not supported yet."
	@exit 1
endif
ifeq ($(ORGANIZATION),)
	@echo "Gearbox: ERROR - You need to install JQ or NodeJS."
	@exit 1
endif
	@echo > /dev/null


################################################################################
info:
	@make info-real BUILD_TYPE="base"
	@make info-real BUILD_TYPE="final"

clean:
	@make clean-real BUILD_TYPE="base"
	@make clean-real BUILD_TYPE="final"

build:
	@make build-real BUILD_TYPE="base"
	@make build-real BUILD_TYPE="final"

push:
	@make push-real BUILD_TYPE="base"
	@make push-real BUILD_TYPE="final"

release:
	@make release-real BUILD_TYPE="base"
	@make release-real BUILD_TYPE="final"

list:
	@make list-real BUILD_TYPE="base"
	@make list-real BUILD_TYPE="final"

log:
	@make log-real BUILD_TYPE="base"
	@make log-real BUILD_TYPE="final"

inspect:
	@make inspect-real BUILD_TYPE="base"
	@make inspect-real BUILD_TYPE="final"

test:
	@make test-real BUILD_TYPE="base"
	@make test-real BUILD_TYPE="final"

readme:
	@cat README.md


################################################################################
info-%:
	@make info-real BUILD_TYPE="$*"

clean-%:
	@make clean-real BUILD_TYPE="$*"

build-%:
	@make build-real BUILD_TYPE="$*"

push-%:
	@make push-real BUILD_TYPE="$*"

release-%:
	@make release-real BUILD_TYPE="$*"

list-%:
	@make list-real BUILD_TYPE="$*"

log-%:
	@make log-real BUILD_TYPE="$*"

inspect-%:
	@make inspect-real BUILD_TYPE="$*"

test-%:
	@make test-real BUILD_TYPE="$*"


################################################################################
info-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	@echo "Gearbox: Not implemented yet."
ifneq ($(MAJORVERSION),)
	@echo "Gearbox: Not implemented yet."
endif
endif


################################################################################
build-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	@echo "Gearbox: Building container."
	@script $(LOG_ARGS) logs/$(LOGFILE) docker build -t $(IMAGE_NAME):$(VERSION) --label gearbox.json='$(call rawJSON)' --label container.organization="$(ORGANIZATION)" --label container.name="$(NAME)" --label container.version="$(VERSION)" --label container.majorversion="$(MAJORVERSION)" --label container.latest="$(LATEST)" --label container.class="$(CLASS)" --label container.network="$(NETWORK)" --label container.ports="$(PORTS)" --label container.volumes="$(VOLUMES)" --label container.restart="$(RESTART)" --label container.args="$(ARGS)" --label container.env="$(ENV)" --build-arg $(ENV)="$(VERSION)" $(BUILD_ARGS) -f $(DOCKERFILE) .
	@echo "Gearbox: Log file saved to \"logs/$(LOGFILE)\""
ifneq ($(MAJORVERSION),)
	@docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):$(MAJORVERSION)
endif
endif


################################################################################
push-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	@if [ -d .git ]; then echo "Gearbox: Pushing changes to GitHub."; git commit -m "Release commit." .. && git push; fi

	@echo "Gearbox: Pushing changes to DockerHub."
	-docker push $(IMAGE_NAME):$(VERSION)
ifneq ($(MAJORVERSION),)
	docker push $(IMAGE_NAME):$(MAJORVERSION)
endif
endif


################################################################################
release-real: build
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	# @make clean-base
	# @make build-base
	@make clean
	@make build
	@make test
	@make push
endif


################################################################################
clean-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	-docker image rm -f $(IMAGE_NAME):$(VERSION)
ifneq ($(MAJORVERSION),)
	-docker image rm -f $(IMAGE_NAME):$(MAJORVERSION)
endif
	@rm -f logs/*.log
endif


################################################################################
list-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	docker image ls $(IMAGE_NAME):$(VERSION)
ifneq ($(MAJORVERSION),)
	docker image ls $(IMAGE_NAME):$(MAJORVERSION)
endif
endif


################################################################################
log-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	@if [ -f "logs/$(LOGFILE)" ]; then script -dp logs/$(LOGFILE) | less -SinR; fi
endif


################################################################################
inspect-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	docker image inspect $(IMAGE_NAME):$(VERSION)
endif


################################################################################
test-real:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

ifneq ($(SKIP),yes)
	@echo "Unit tests not defined for this container."
	@# make -k stop; make -k rm
	@# make -k clean; make -k build; make -k create; make -k start
endif


################################################################################
# Container related commands.

create:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

	docker create --name $(CONTAINER_NAME) $(RESTART)  $(NETWORK) $(PORTS) $(ARGS) $(VOLUMES) $(IMAGE_NAME):$(VERSION)


################################################################################
shell:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

	docker run --rm --name $(CONTAINER_NAME)-shell -i -t $(NETWORK) $(PORTS) $(ARGS) $(VOLUMES) $(IMAGE_NAME):$(VERSION) /bin/bash -l


################################################################################
run:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

	docker run --rm --name $(CONTAINER_NAME) $(NETWORK) $(PORTS) $(ARGS) $(VOLUMES) $(IMAGE_NAME):$(VERSION)


################################################################################
start:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

	docker start $(CONTAINER_NAME)


################################################################################
stop:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

	docker stop $(CONTAINER_NAME)


################################################################################
rm:
	@make check-config BUILD_TYPE=$(BUILD_TYPE)

	docker container rm -f $(CONTAINER_NAME)


################################################################################

