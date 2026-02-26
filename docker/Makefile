# SEE ALSO: Dockerfile-almalinux
ALMA_VERSION =
OIDC_AGENT_VERSION =
JWT_AGENT_VERSION =
#ALMA_VERSION = 10
#OIDC_AGENT_VERSION = 4.5.2
#OIDC_AGENT_VERSION = 5.3.4
#JWT_AGENT_VERSION = 1.1.1

DOCKER_CMD = podman
DOCKER_CMD_NAME := $(shell basename $(DOCKER_CMD))

DOCKER_FILE = Dockerfile-almalinux

NAME = hpcissh
IMAGE_TAG = localdev
IMAGE_NAME = $(NAME)-almalinux$(ALMA_VERSION)
IMAGE_NAME_FULL = $(IMAGE_NAME):$(IMAGE_TAG)

USER_UID := $(shell id -u)
USER_GID := $(shell id -g)
USER_NAME := $(shell id -un)
USER_HOST_HOME = $(HOME)
MOUNT_HOST_HOME=/HOST_HOMEDIR
CONTAINER_HOME = /home/$(USER_NAME)
CONTAINER_SHELL = /bin/bash

LANG = ja_JP.UTF-8
TZ = Asia/Tokyo

DEBUG_X = yes

DOCKER_INTERACTIVE := $(shell test -t 0 && echo "-it" || echo "-i")

RUN_OPTS = $(DOCKER_INTERACTIVE)
ifeq ($(DOCKER_CMD_NAME),podman)
  RUN_OPTS += --init
  RUN_OPTS += --hostname $(NAME)
  RUN_OPTS += --userns=keep-id
endif
ifeq ($(DOCKER_CMD_NAME),docker)
  RUN_OPTS += --init
  RUN_OPTS += --hostname $(NAME)
endif

BUILD_OPTS =
ifneq ($(ALMA_VERSION),)
  BUILD_OPTS += --build-arg ALMA_VERSION=$(ALMA_VERSION)
endif
ifneq ($(OIDC_AGENT_VERSION),)
  BUILD_OPTS += --build-arg OIDC_AGENT_VERSION=$(OIDC_AGENT_VERSION)
endif
ifneq ($(JWT_AGENT_VERSION),)
  BUILD_OPTS += --build-arg JWT_AGENT_VERSION=$(JWT_AGENT_VERSION)
endif

.PHONY: build
build:
	$(DOCKER_CMD) build -f $(DOCKER_FILE) -t $(IMAGE_NAME_FULL) \
	$(BUILD_OPTS) ../

define docker_run
	$(DOCKER_CMD) run $(1) $(RUN_OPTS) \
	--name $(NAME) \
	--mount type=bind,src=$(USER_HOST_HOME),dst=/HOST_HOMEDIR \
	-e USER_UID=$(USER_UID) \
	-e USER_GID=$(USER_GID) \
	-e USER_NAME=$(USER_NAME) \
	-e MOUNT_HOST_HOME=$(MOUNT_HOST_HOME) \
	-e CONTAINER_HOME=$(CONTAINER_HOME) \
	-e CONTAINER_SHELL=$(CONTAINER_SHELL) \
	-e LANG=$(LANG) \
	-e TZ=$(TZ) \
	-e DEBUG_X=$(DEBUG_X) \
	$(IMAGE_NAME_FULL) $(2)
endef

.PHONY: run-shell
run-shell:
	$(call docker_run, --rm)

.PHONY: start
run:
	$(call docker_run, --detach, tail -f /var/log/messages)

.PHONY: start
start:
	$(DOCKER_CMD) start $(NAME)

.PHONY: stop
stop:
	$(DOCKER_CMD) stop $(NAME)

.PHONY: rm
rm:
	$(DOCKER_CMD) rm $(NAME)

.PHONY: kill
kill:
	-$(DOCKER_CMD) kill $(NAME)

.PHONY: ps
ps:
	$(DOCKER_CMD) ps

.PHONY: logs
logs:
	$(DOCKER_CMD) logs $(NAME)

.PHONY: logs-f
logs-f:
	$(DOCKER_CMD) logs -f $(NAME)

.PHONY: shell
shell:
	$(DOCKER_CMD) exec -it -u $(USER_UID) -w $(CONTAINER_HOME) $(NAME) /bin/bash

.PHONY: test
test:
	$(call docker_run, --rm, /test-container.sh)

.PHONY: help
help: DEBUG_X = no
help:
	$(call docker_run, --rm, --help)
