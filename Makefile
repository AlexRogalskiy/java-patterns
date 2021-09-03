# Since we rely on paths relative to the makefile location, abort if make isn't being run from there.
$(if $(findstring /,$(MAKEFILE_LIST)),$(error Please only invoke this makefile from the directory it resides in))

# SHELL defines the shell that the Makefile uses.
# We also set -o pipefail so that if a previous command in a pipeline fails, a command fails.
# http://redsymbol.net/articles/unofficial-bash-strict-mode
SHELL := /bin/bash

# Set V=1 on the command line to turn off all suppression. Many trivial
# commands are suppressed with "@", by setting V=1, this will be turned off.
ifeq ($(V),1)
	AT :=
else
	AT := @
endif

IMAGE ?= styled-java-patterns
TAG ?= latest

# UNAME_OS stores the value of uname -s.
UNAME_OS := $(shell uname -s)
# UNAME_ARCH stores the value of uname -m.
UNAME_ARCH := $(shell uname -m)

# TMP_BASE is the base directory used for TMP.
# Use TMP and not TMP_BASE as the temporary directory.
TMP_BASE := .tmp
# TMP_COVERAGE is where we store code coverage files.
TMP_COVERAGE := $(TMP_BASE)/coverage

UTILS := docker tilt helm
# Make sure that all required utilities can be located.
UTIL_CHECK := $(or $(shell which $(UTILS) >/dev/null && echo 'ok'),$(error Did you forget to install `docker` and `tilt` after cloning the repo? At least one of the required supporting utilities not found: $(UTILS)))
DIRS := $(shell ls -ad -- */ | grep -v release)

# Run all by default when "make" is invoked.
.DEFAULT_GOAL := list

# Default target (by virtue of being the first non '.'-prefixed in the file).
.PHONY: _no-target-specified
_no-target-specified:
	$(error Please specify the target to make - `make list` shows targets)

# Lists all targets defined in this makefile.
.PHONY: list
list:
	$(AT)$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | command grep -v -e '^[^[:alnum:]]' -e '^$@$$command ' | sort

# Lists all dirs (except `release`).
.PHONY: dirs
dirs:
	echo "$(DIRS)"

# Run version command.
.PHONY: versions
versions:
	$(AT) echo
	docker --version
	$(AT) echo
	tilt version
	$(AT) echo
	helm version
	$(AT) echo

# Clean removes all temporary files.
.PHONY: clean
clean:
	rm -rf $(TMP_BASE)
	rm -rf dist
	rm -rf release

# Ensures that the git workspace is clean.
.PHONY: _ensure-clean
_ensure-clean:
	$(AT)[ -z "$$((git status --porcelain --untracked-files=no || echo err) | command grep -v 'CHANGELOG.md')" ] || { echo "Workspace is not clean; please commit changes first." >&2; exit 2; }

# Run docker build command.
.PHONY: docker-build
docker-build: _ensure-clean
	docker build -f Dockerfile -t $(IMAGE):$(TAG) .

# Run docker start command.
.PHONY: docker-start
docker-start:
	docker-compose -f docker-compose.yml up -d

# Run docker stop command.
.PHONY: docker-stop
docker-stop:
	docker-compose -f docker-compose.yml down -v --remove-orphans

# Run tilt start command.
.PHONY: tilt-start
tilt-start:
	tilt up

# Run tilt stop command.
.PHONY: tilt-stop
tilt-stop:
	tilt down --delete-namespaces

# Run helm lint command.
.PHONY: helm-lint
helm-lint:
	helm lint charts --values charts/values.yaml

# Run helm start command.
.PHONY: helm-start
helm-start:
	helm upgrade --install backend-java-patterns -f charts/values.yaml --create-namespace --namespace webapp charts

# Run helm stop command.
.PHONY: helm-stop
helm-stop:
	helm uninstall backend-java-patterns --namespace webapp

# Run helm package command.
.PHONY: helm-package
helm-package:
	mkdir -p release/charts
	helm package charts --dependency-update --destination release/charts

# Run helm dev command.
.PHONY: helm-dev
helm-dev: clean helm-lint helm-package

# Run okteto build command.
.PHONY: okteto
okteto:
	okteto build -t alexanderr/styled-java-patterns .
	okteto build -t okteto/styled-java-patterns .
