############################################################################
# Variables
############################################################################

# Since we rely on paths relative to the makefile location, abort if make isn't being run from there.
$(if $(findstring /,$(MAKEFILE_LIST)),$(error Please only invoke this makefile from the directory it resides in))

# SHELL defines the shell that the Makefile uses.
# We also set -o pipefail so that if a previous command in a pipeline fails, a command fails.
# http://redsymbol.net/articles/unofficial-bash-strict-mode
SHELL := /bin/bash -o errexit -o nounset

PYTHON := python3
NPM := npm

TIME_LONG	= `date +%Y-%m-%d' '%H:%M:%S`
TIME_SHORT	= `date +%H:%M:%S`
TIME		= $(TIME_SHORT)

BLUE         := $(shell printf "\033[34m")
YELLOW       := $(shell printf "\033[33m")
RED          := $(shell printf "\033[31m")
GREEN        := $(shell printf "\033[32m")
CNone        := $(shell printf "\033[0m")

INFO	= echo ${TIME} ${BLUE}[ .. ]${CNone}
WARN	= echo ${TIME} ${YELLOW}[WARN]${CNone}
ERR		= echo ${TIME} ${RED}[FAIL]${CNone}
OK		= echo ${TIME} ${GREEN}[ OK ]${CNone}
FAIL	= (echo ${TIME} ${RED}[FAIL]${CNone} && false)

CLUSTER_NAME := backend-java-patterns
CLUSTER_NAMESPACE := webapp

VENV_NAME := venv
VENV_BIN=$(VENV_NAME)/bin
VENV_PIP=$(VENV_BIN)/pip3
VENV_PYTHON=$(VENV_BIN)/python3

MKDOCS_BUILD_OPTS = --clean --strict --verbose
MKDOCS_SERVE_OPTS = --verbose --dirtyreload

RELEASE_NAME := release
GH_PAGES_NAME := site

cred := $(shell echo -e "\033[0;31m")
cyellow := $(shell echo -e "\033[0;33m")
cend := $(shell echo -e "\033[0m")

# Set V=1 on the command line to turn off all suppression. Many trivial
# commands are suppressed with "@", by setting V=1, this will be turned off.
ifeq ($(V),1)
	AT :=
else
	AT := @
endif

# Optional flag to run target in a docker container.
# (example `make test USE_DOCKER=true`)
ifeq ($(USE_DOCKER),true)
	DOCKER_CMD := docker compose
endif

IMAGE ?= styled-java-patterns
OKTETO_IMAGE ?= okteto/$(IMAGE)
DOCKER_IMAGE ?= alexanderr/$(IMAGE)
TAG ?= latest

# UNAME_OS stores the value of uname -s.
UNAME_OS := $(shell uname -s)
# UNAME_ARCH stores the value of uname -m.
UNAME_ARCH := $(shell uname -m)
# ROOT_DIR stored git root directory
ROOT_DIR=$(git rev-parse --show-toplevel)
# ORIGINAL_BRANCH stored git branch name
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# TMP_BASE is the base directory used for TMP.
# Use TMP and not TMP_BASE as the temporary directory.
TMP_BASE := .tmp
# TMP_COVERAGE is where we store code coverage files.
TMP_COVERAGE := $(TMP_BASE)/coverage

UTILS := docker tilt helm
# Make sure that all required utilities can be located.
UTIL_CHECK := $(or $(shell which $(UTILS) >/dev/null && echo 'ok'),$(error Did you forget to install `docker` and `tilt` after cloning the repo? At least one of the required supporting utilities not found: $(UTILS)))
DIRS := $(shell ls -ad -- */)

# Run all by default when "make" is invoked.
.DEFAULT_GOAL := help

############################################################################
# Common
############################################################################

# Default target (by virtue of being the first non '.'-prefixed in the file).
.PHONY: _no-target-specified
_no-target-specified:
	$(error Please specify the target to make - `make list` shows targets)

# Create virtual environment.
.PHONY: _venv
_venv:
	virtualenv $(VENV_NAME)
	. $(VENV_BIN)/activate
	@echo
	@echo -e "$(cred)Virtual env created. The source pages are in $(VENV_NAME) directory.$(cend)"
	@echo

# This rule creates a file named .env that is used by docker-compose for passing
# the USER_ID and GROUP_ID arguments to the Docker image.
.env: ## Setup step for using using docker-compose with make target.
	@touch .env
ifneq ($(OS),Windows_NT)
ifneq ($(shell uname -s), Darwin)
	@echo USER_ID=$(shell id -u) >> .env
	@echo GROUP_ID=$(shell id -g) >> .env
endif
endif

# Create help information.
.PHONY: help
##= all: to run linting & format tasks
##= clean: to remove temporary directories
##= deps: to install dependencies
##= diff: to list modified files
##= dirs: to list directories
##= docker-build: to build docker image
##= docker-start: to start docker image
##= docker-stop: to stop docker image
##= gh-pages: to create new version of documentation and publish on GitHub pages
##= git-authors: to lint git authors
##= git-pull: to pull remote changes
##= helm-dev: to lint and create helm package
##= helm-lint: to lint helm charts
##= helm-package: to package helm chart
##= helm-start: to run k8s cluster
##= helm-stop : to stop k8s cluster
##= help: to list all make targets with description
##= install-pip: to install python pip module
##= list: to list all make targets
##= local-build: to build documentation locally
##= local-run: to run documentation locally
##= okteto: to build okteto image
##= tilt-start: to start development k8s cluster
##= tilt-stop: to stop development k8s cluster
##= venv-build: to build documentation in virtual environment
##= venv-run: to run documentation in virtual environment
##= versions: to list commands versions
help:
	@echo
	@echo
	@echo "Please use [make <target>] where <target> is one of:"
	@echo
	$(AT)sed -n 's/^##=//p' $(MAKEFILE_LIST) 2>/dev/null | column -t -s ':' |  sed -e 's/^/ /'
	@echo
	@echo

# Lists all targets defined in this makefile.
.PHONY: list
list:
	$(AT)$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | command grep -v -e '^[^[:alnum:]]' -e '^$@$$command ' | sort

# Lists all dirs.
.PHONY: dirs
dirs:
	echo "$(DIRS)"
	@echo
	@echo -e "$(cred)Directory list finished.$(cend)"
	@echo

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
	@echo
	@echo -e "$(cred)Versions list finished.$(cend)"
	@echo

# Clean removes all temporary files.
.PHONY: clean
clean:
	rm -rf $(TMP_BASE)
	rm -rf $(RELEASE_NAME)
	rm -rf $(GH_PAGES_NAME)
	rm -rf $(VENV_NAME)
	@echo
	@echo -e "$(cred)Clean finished.$(cend)"
	@echo

# Ensures that the git workspace is clean.
.PHONY: _ensure-clean
_ensure-clean:
	$(AT)[ -z "$$((git status --porcelain --untracked-files=no || echo err) | command grep -v 'CHANGELOG.md')" ] || { echo "Workspace is not clean; please commit changes first." >&2; exit 2; }

# Ensure docker tag command.
.PHONY: _ensure-docker-tag
_ensure-docker-tag:
ifndef DOCKER_TAG
	$(error Please invoke with `make DOCKER_TAG=<tag> docker-build`)
endif

# Run docker build command.
.PHONY: docker-build
docker-build: _ensure-docker-tag
	chmod +x ./scripts/docker-build.sh
	./scripts/docker-build.sh $(DOCKER_TAG)

# Run docker start command.
.PHONY: docker-start
docker-start: .env
	chmod +x ./scripts/docker-compose-start.sh
	./scripts/docker-compose-start.sh

# Run docker stop command.
.PHONY: docker-stop
docker-stop:
	chmod +x ./scripts/docker-compose-stop.sh
	./scripts/docker-compose-stop.sh

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
	helm upgrade --install $(CLUSTER_NAME) -f charts/values.yaml --create-namespace --namespace $(CLUSTER_NAMESPACE) charts

# Run helm stop command.
.PHONY: helm-stop
helm-stop:
	helm uninstall $(CLUSTER_NAME) --namespace $(CLUSTER_NAMESPACE)

# Run helm package command.
.PHONY: helm-package
helm-package:
	mkdir -p $(RELEASE_NAME)/charts
	helm package charts --dependency-update --destination $(RELEASE_NAME)/charts
	@echo
	@echo -e "$(cred)Helm packages build finished.$(cend)"
	@echo

# Run helm dev command.
.PHONY: helm-dev
helm-dev: clean helm-lint helm-package

# Run okteto build command.
.PHONY: okteto
okteto:
	okteto build -t $(DOCKER_IMAGE) .
	okteto build -t $(OKTETO_IMAGE) .
	@echo
	@echo -e "$(cred)Okteto images build finished.$(cend)"
	@echo

# Install pip command.
.PHONY: install-pip
install-pip:
	wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O $(TMPDIR)/get-pip.py
	$(PYTHON) $(TMPDIR)/get-pip.py
	@echo
	@echo -e "$(cred)Pip installed.$(cend)"
	@echo

# Run local build command.
.PHONY: local-build
local-build:
	$(PYTHON) -m pip install -r ./docs/requirements.txt --disable-pip-version-check
	$(PYTHON) -m mkdocs build $(MKDOCS_BUILD_OPTS) --config-file mkdocs.yml
	@echo
	@echo -e "$(cred)Python documentation build finished.$(cend)"
	@echo

# Run local run command.
.PHONY: local-run
local-run: local-build
	$(PYTHON) -m mkdocs serve $(MKDOCS_SERVE_OPTS)

# Run venv build command.
.PHONY: venv-build
venv-build: _venv
	$(VENV_PYTHON) -m pip install -r ./docs/requirements.txt --disable-pip-version-check --no-cache-dir --prefer-binary
	$(VENV_PYTHON) -m mkdocs build $(MKDOCS_BUILD_OPTS) --config-file mkdocs.yml
	@echo
	@echo -e "$(cred)Build finished. The source pages are in $(VENV_NAME) directory.$(cend)"
	@echo
	exit

# Run venv run command.
.PHONY: venv-run
venv-run: venv-build
	$(VENV_PYTHON) -m mkdocs serve $(MKDOCS_SERVE_OPTS)

# Run github pages deploy command.
.PHONY: gh-pages
gh-pages:
	$(PYTHON) -m mkdocs --verbose gh-deploy --force --remote-branch gh-pages
	@echo
	@echo -e "$(cred)GitHub pages generated.$(cend)"
	@echo

# Run npm install command.
.PHONY: deps
deps:
	$(NPM) install
	@echo
	@echo -e "$(cred)Install finished.$(cend)"
	@echo

# Run npm all command.
.PHONY: all
all:
	$(NPM) run all
	@echo
	@echo -e "$(cred)Build finished.$(cend)"
	@echo

# Run git diff command.
.PHONY: diff
diff:
	$(AT)git diff --diff-filter=d --name-only

# Run git authors command.
.PHONY: git-authors
git-authors:
	@echo
	$(AT)find . -name ".git" -type d -exec git --git-dir={} --work-tree="$(PWD)"/{} config --get remote.origin.url \; -exec git --git-dir={} --work-tree="$(PWD)"/{} --no-pager shortlog -sn \;
	@echo

# Run git pull command.
.PHONY: git-pull
git-pull:
	@echo
	$(AT)find . -name ".git" -type d | xargs -P10 -I{} git --git-dir={} --work-tree="$(PWD)"/{} pull origin master
	@echo

# Run install link checker command.
.PHONY: install-link-checker
install-link-checker:
	$(AT)[[ -f "./scripts/htmltest.sh" ]] || curl https://htmltest.wjdp.uk -o ./scripts/htmltest.sh

# Run setup link checker command.
.PHONY: setup-link-checker
setup-link-checker:
	chmod +x ./scripts/htmltest.sh
	./scripts/htmltest.sh -d

# Run run link checker command.
.PHONY: run-link-checker
run-link-checker:
	chmod +x ./bin/htmltest
	./bin/htmltest --conf .htmltest.yml

# Run check links command.
.PHONY: check-links
check-links: install-link-checker setup-link-checker run-link-checker
