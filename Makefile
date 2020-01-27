#
# Standard top level Makefile used to build a Docker container for Gearbox - https://github.com/gearboxworks/gearbox/
# 

VERSIONS = $(sort $(dir $(wildcard */)))
COMMENT := Release commit.
BASEDIR = $(shell pwd)

.PHONY: help build push push-docker push-git release clean list

################################################################################
# Image related commands.

help:
	@cat README.md

build:
	@echo "################################################################################"
	@echo "Gearbox: Building for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), make -C $(BASEDIR)/$(ver) $@;)

push:
	@make push-docker
	@make push-git

push-docker:
	@echo "################################################################################"
	@echo "Gearbox: Pushing to DockerHub for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), make -C $(BASEDIR)/$(ver) $@;)

push-git:
	@echo "################################################################################"
	@echo "Gearbox: Pushing to GitHub."
	if [ -d .git ]; then git commit -m "$(COMMENT)" . && git push; fi

release:
	@echo "################################################################################"
	$(foreach ver,$(VERSIONS), make -C $(BASEDIR)/$(ver) $@;)

clean:
	@echo "################################################################################"
	@echo "Gearbox: Cleaning up for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), make -C $(BASEDIR)/$(ver) $@;)

list:
	@echo "################################################################################"
	@echo "Gearbox: Listing for versions: $(VERSIONS)"
	$(foreach ver,$(VERSIONS), make -C $(BASEDIR)/$(ver) $@;)

################################################################################
default: help

