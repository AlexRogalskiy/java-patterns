################################################################################
# Dependencies                                                                 #
################################################################################

# MAKE_DIRS stores makefile directories
MAKE_DIRS							:= makefiles

include $(foreach dir,$(MAKE_DIRS),$(sort $(wildcard $(dir)/*.mk)))
include $(foreach dir,$(MAKE_DIRS),$(sort $(wildcard $(dir)/*/*.mk)))

################################################################################
# Variables                                                               		 #
################################################################################

# Since we rely on paths relative to the makefile location, abort if make isn't being run from there.
$(if $(findstring "..",$(MAKEFILE_LIST)),$(error Please only invoke this makefile from the directory it resides in))
# Make sure that all required utilities can be located.
UTILS_CHECK := $(or $(shell which $(UTILS) >/dev/null && echo 'ok'),$(error Did you forget to install $(UTILS) after cloning the repo? At least one of the required supporting utilities not found: $(UTILS)))

# DOCKER_REGISTRY defines docker registry
DOCKER_REGISTRY 			:= docker.io
# DOCKER_ORG defines docker organization
DOCKER_ORG 						:= nullables
# DOCKER_IMAGE_NAME defines docker image name
DOCKER_IMAGE_NAME 		:= styled-java-patterns
# IMAGE_NAME defines image name
IMAGE_NAME         		:= $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(DOCKER_IMAGE_NAME):$(DOCKER_VERSION)
# MUTABLE_IMAGE_NAME defines mutable image name
MUTABLE_IMAGE_NAME 		:= $(DOCKER_REGISTRY)/$(DOCKER_ORG)/$(DOCKER_IMAGE_NAME):$(MUTABLE_DOCKER_VERSION)
# OKTETO_IMAGE_NAME defines okteto image name
OKTETO_IMAGE_NAME 		:= okteto/$(DOCKER_IMAGE_NAME)
# DOCKER_HUB_IMAGE_NAME defines docker hub image name
DOCKER_HUB_IMAGE_NAME := alexanderr/$(DOCKER_IMAGE_NAME)

# CLUSTER_NAME defines cluster name
CLUSTER_NAME 					:= backend-java-patterns
# CLUSTER_NAMESPACE defines cluster namespace
CLUSTER_NAMESPACE 		:= webapp

# SHELL stores the shell that the Makefile uses.
SHELL 								:= $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
	 												else if [ -x /bin/bash ]; then echo /bin/bash -o errexit -o nounset; \
	 												else echo sh; fi; fi)
# PYTHON_CMD stores python binary
PYTHON_CMD 						:= $(shell command -v python3 2> /dev/null || type -p python)
# SED_CMD stores stream editor binary
SED_CMD 							:= $(shell command -v gsed 2> /dev/null || command -v sed 2> /dev/null || type -p sed)
# DOCKER_CMD stores docker binary
DOCKER_CMD 						:= $(shell command -v docker 2> /dev/null || command -v podman 2> /dev/null || type -p docker)
# DOCKER_COMPOSE_CMD stores docker-compose binary
DOCKER_COMPOSE_CMD 		:= $(shell command -v docker-compose 2> /dev/null || command -v docker compose 2> /dev/null || type -p docker-compose)
# NPM_CMD stores npm binary
NPM_CMD 							:= $(shell command -v npm 2> /dev/null || type -p npm)
# SKAFFOLD_CMD stores skaffold binary
SKAFFOLD_CMD 					:= $(shell command -v skaffold 2> /dev/null || type -p skaffold)
# TILT_CMD stores tilt binary
TILT_CMD 							:= $(shell command -v tilt 2> /dev/null || type -p tilt)
# HELM_CMD stores helm binary
HELM_CMD 							:= $(shell command -v helm 2> /dev/null || type -p helm)
# OKTETO_CMD stores okteto binary
OKTETO_CMD 						:= $(shell command -v okteto 2> /dev/null || type -p okteto)
# GIT_CMD stores git binary
GIT_CMD 							:= $(shell command -v git 2> /dev/null || type -p git)

# DOCKER_DIR stores docker configurations
DOCKER_DIR 						:= $(GIT_ROOT_DIR)
# SCRIPT_DIR stores script configurations
SCRIPT_DIR 						:= scripts

# VERBOSE stores logging output verbosity
VERBOSE 							:= false

# VENV_NAME stores virtual environment name
VENV_NAME 						:= venv
# VENV_BIN stores virtual environment binary directory
VENV_BIN							:= $(VENV_NAME)/bin
# VENV_PIP stores virtual environment pip binary
VENV_PIP							:= $(VENV_BIN)/pip3
# VENV_PYTHON stores virtual environment python binary
VENV_PYTHON						:= $(VENV_BIN)/python3

# PIP_OPTS stores pip options
PIP_OPTS		 		      := --disable-pip-version-check --no-cache-dir
# PIP_BUILD_OPTS stores pip build options
PIP_BUILD_OPTS		 		:= $(PIP_OPTS) --no-compile --prefer-binary
# MKDOCS_BUILD_OPTS stores mkdocs build options
MKDOCS_BUILD_OPTS 		:= --clean --strict --verbose --config-file mkdocs.yml
# MKDOCS_DEPLOY_OPTS stores mkdocs deploy options
MKDOCS_DEPLOY_OPTS 		:= --verbose --clean --force --remote-branch gh-pages
# MKDOCS_SERVE_OPTS stores mkdocs serve options
MKDOCS_SERVE_OPTS 		:= --verbose --dirtyreload --dev-addr=0.0.0.0:8000 --config-file mkdocs.yml
# HTMLTEST stores htmltest binary
HTMLTEST 							:= htmltest
# HTMLTEST_OPTS stores htmltest binary arguments
HTMLTEST_OPTS					:= --skip-external --conf .htmltest.yml

# CHART_RELEASE_DIR stores chart release folder
CHART_RELEASE_DIR 		:= release
# GITHUB_PAGES_DIR stores github pages folder
GITHUB_PAGES_DIR 			:= site

# REQUIRED_TOOLS stores required binary tools
REQUIRED_TOOLS        := $(UTILS)

# SAVE_LOG stores make logs
SAVE_LOG = 2>&1 | tee "$(PWD)/logs/$(DOCKER_IMAGE_NAME).log"

# VARS stores printing variables
VARS += DOCKER_IMAGE_NAME
VARS += IMAGE_NAME MUTABLE_IMAGE_NAME
VARS += MUTABLE_IMAGE_NAME
VARS += OKTETO_IMAGE_NAME
VARS += DOCKER_HUB_IMAGE_NAME
VARS += SHELL
VARS += SED_CMD
VARS += DOCKER_CMD
VARS += DOCKER_COMPOSE_CMD
VARS += PYTHON_CMD
VARS += NPM_CMD
VARS += SKAFFOLD_CMD
VARS += TILT_CMD
VARS += HELM_CMD
VARS += GIT_CMD
VARS += DOCKER_DIR
VARS += VERBOSE

################################################################################
# Targets                                                               		   #
################################################################################

# Run all by default when "make" is invoked.
.DEFAULT_GOAL := help

$(REQUIRED_TOOLS):
	@hash $@ 2>/dev/null || (echo "please install $@" && exit 1)

# Check docker image running.
.PHONY: _check_docker_image
_check_docker_image:
	@if [[ -n "$$($(AT)$(DOCKER_CMD) ps --format '{{ .Names }}' --filter name="^/$(IMAGE_NAME)\$$")" ]]; then \
		printf "**************************************************************************\n" ; \
		printf "Not launching new container because old container is still running.\n"; \
		printf "Exit all running container shells gracefully or kill the container with\n\n"; \
		printf "  docker kill %s\n\n" "$(IMAGE_NAME)" ; \
		printf "**************************************************************************\n" ; \
		exit 9 ; \
	fi

# Default target (by virtue of being the first non '.'-prefixed in the file).
.PHONY: _no-target-specified
_no-target-specified:
	$(error Please specify the target to make - `make list` shows targets)

# Create virtual environment.
.PHONY: _venv
_venv:
	$(AT)virtualenv $(VENV_NAME)
	. $(VENV_BIN)/activate
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Virtual env created. The source pages are in $(VENV_NAME) directory.$(COLOR_NORMAL)"
	$(AT)echo

# Create environment variables
.PHONY: _check_env
_check_env:
ifneq ($(SYS_OS),Windows_NT)
ifneq ($(SYS_OS), Darwin)
	$(AT)echo USER_ID=$(UID) >> .env
	$(AT)echo GROUP_ID=$(GID) >> .env
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
##= docker-restart: to restart docker image
##= gh-pages: to create new version of documentation and publish on GitHub pages
##= git-authors: to lint git authors
##= git-pull: to pull remote changes
##= helm-dev: to lint and create helm package
##= helm-lint: to lint helm charts
##= helm-package: to package helm chart
##= helm-start: to run k8s cluster
##= helm-stop : to stop k8s cluster
##= skaffold-start: to run containers via skaffold
##= skaffold-stop : to destroy containers via skaffold
##= help: to list all make targets with description
##= install-pip: to install python pip module
##= list: to list all make targets
##= local-install: to install dependencies locally
##= local-build: to build documentation locally
##= local-run: to run documentation locally
##= okteto: to build okteto image
##= tilt-start: to start development k8s cluster
##= tilt-stop: to stop development k8s cluster
##= venv-build: to build documentation in virtual environment
##= venv-run: to run documentation in virtual environment
##= versions: to list commands versions
help:
	$(AT)echo
	$(AT)echo
	$(AT)echo "Please use [make <target>] where <target> is one of:"
	$(AT)echo
	$(AT)$(SED_CMD) -n 's/^##=//p' $(MAKEFILE_LIST) 2>/dev/null | column -t -s ':' |  $(SED_CMD) -e 's/^/ /'
	$(AT)echo
	$(AT)echo

# Lists all targets defined in this makefile.
.PHONY: list
list:
	$(AT)$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | command grep -v -e '^[^[:alnum:]]' -e '^$@$$command ' | sort

# Lists all dirs.
.PHONY: dirs
dirs:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running dirs command$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)echo "$(shell ls -ad -- */)"
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Directory list finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run version command.
.PHONY: versions
versions:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running versions command.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)$(DOCKER_CMD) --version
	$(AT)echo
	$(AT)$(TILT_CMD) version
	$(AT)echo
	$(AT)$(HELM_CMD) version
	$(AT)echo
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Versions list finished.$(COLOR_NORMAL)"
	$(AT)echo

# Clean removes all temporary files.
.PHONY: clean
clean:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running clean command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)rm -rf $(TMP_BASE)
	$(AT)rm -rf $(CHART_RELEASE_DIR)
	$(AT)rm -rf $(GITHUB_PAGES_DIR)
	$(AT)rm -rf $(VENV_NAME)
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Clean finished.$(COLOR_NORMAL)"
	$(AT)echo

# Ensures that the git workspace is clean.
.PHONY: _ensure-clean
_ensure-clean:
	$(AT)[ -z "$$(($(GIT_CMD) status --porcelain --untracked-files=no || echo err) | command grep -v 'CHANGELOG.md')" ] || { echo "Workspace is not clean; please commit changes first." >&2; exit 2; }

# Ensure docker tag command.
.PHONY: _ensure-docker-tag
_ensure-docker-tag:
ifndef DOCKER_TAG
	$(error Please invoke with `make DOCKER_TAG=<tag> docker-build`)
endif

# Ensure skaffold tag command.
.PHONY: _ensure-skaffold-tag
_ensure-skaffold-tag:
ifndef SKAFFOLD_TAG
	$(error Please invoke with `make SKAFFOLD_TAG=[ docker | helm | kubectl | kustomize ] skaffold[ start | stop ]`)
endif

# Run docker scan command.
.PHONY: docker-scan
docker-scan:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-scan command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) scan --json --group-issues --dependency-tree --file Dockerfile "$(IMAGE_NAME)" $(SAVE_LOG)
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker scan command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker table command.
.PHONY: docker-table
docker-table:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-table command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}" $(SAVE_LOG)
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker table command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker code lint command.
.PHONY: docker-code-lint
docker-code-lint:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-code-lint command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) run \
    --interactive \
    $(DOCKER_FLAGS) \
		--platform=linux/amd64 \
		--rm \
		--ulimit memlock=-1:-1 \
		--user $(SYS_USER_GROUP) \
		--volume $(PWD)/:/data/project/ \
		--publish 8080:8080 \
		jetbrains/qodana-jvm-community --show-report \
		$(SAVE_LOG)
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker code lint command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker pandoc command.
.PHONY: docker-pandoc
docker-pandoc:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-pandoc command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) run \
    --interactive \
    $(DOCKER_FLAGS) \
		--platform=linux/amd64 \
		--rm \
		--user $(SYS_USER_GROUP) \
		--volume "$(PWD):/data" \
		pandoc/latex README.md -o README.pdf \
		$(SAVE_LOG)
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker pandoc command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker clean command.
.PHONY: docker-clean
docker-clean: docker-stop docker-remove

# Run docker remove container command.
.PHONY: docker-remove
docker-remove:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-remove command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) container rm --force "$(DOCKER_IMAGE_NAME)" > /dev/null
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker remove command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker remove all images command.
.PHONY: docker-remove-all
docker-remove-all:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-remove-all command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) images | grep $(DOCKER_IMAGE_NAME) | awk '{print $3}' | xargs --no-run-if-empty $(DOCKER_CMD) rmi --force
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker remove all command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker build command.
.PHONY: docker-build
docker-build: _ensure-docker-tag
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-build command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-build.sh
	$(AT)$(SCRIPT_DIR)/docker-build.sh $(DOCKER_TAG) $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker build command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker rebuild command.
.PHONY: docker-rebuild
docker-rebuild: _ensure-docker-tag
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-rebuild command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-rebuild.sh
	$(AT)$(SCRIPT_DIR)/docker-rebuild.sh $(DOCKER_TAG) $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker rebuild command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker start command.
.PHONY: docker-start
docker-start: _check_docker_image
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-start command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(AT)$(SCRIPT_DIR)/docker-compose.sh start $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker start command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker stop command.
.PHONY: docker-stop
docker-stop:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-stop command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(AT)$(SCRIPT_DIR)/docker-compose.sh stop $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker stop command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker restart command.
.PHONY: docker-restart
docker-restart:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-restart command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(AT)$(SCRIPT_DIR)/docker-compose.sh restart $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker restart command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker logs command.
.PHONY: docker-logs
docker-logs:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-logs command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(AT)$(SCRIPT_DIR)/docker-compose.sh logs $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker logs command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker ps command.
.PHONY: docker-ps
docker-ps:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-ps command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(AT)$(SCRIPT_DIR)/docker-compose.sh ps $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker ps command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker pull command.
.PHONY: docker-pull
docker-pull:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-pull command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(AT)$(SCRIPT_DIR)/docker-compose.sh pull $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker pull command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run tilt start command.
.PHONY: tilt-start
tilt-start:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running tilt-start command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(TILT_CMD) up
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Tilt start command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run tilt stop command.
.PHONY: tilt-stop
tilt-stop:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running tilt-stop command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(TILT_CMD) down --delete-namespaces
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Tilt stop command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run skaffold deploy command.
.PHONY: skaffold-start
skaffold-start: _ensure-skaffold-tag
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running skaffold-start command.$(COLOR_NORMAL)"
  $(AT)echo
  ## kubectl config use-context docker-desktop
	$(AT)SKAFFOLD_NO_PRUNE=true $(SKAFFOLD_CMD) dev --filename='skaffold.$(SKAFFOLD_TAG).yaml' --timestamps=false --update-check=true --interactive=true --no-prune=false --cache-artifacts=true
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Skaffold start command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run skaffold destroy command.
.PHONY: skaffold-stop
skaffold-stop: _ensure-skaffold-tag
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running skaffold-stop command.$(COLOR_NORMAL)"
  $(AT)echo
  ## kubectl config use-context docker-desktop
	$(AT)$(SKAFFOLD_CMD) delete --filename='skaffold.$(SKAFFOLD_TAG).yaml'
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Skaffold stop command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run helm lint command.
.PHONY: helm-lint
helm-lint:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running helm-lint command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(HELM_CMD) lint charts --values charts/values.yaml
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Helm lint command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run helm start command.
.PHONY: helm-start
helm-start:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running helm-start command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(HELM_CMD) upgrade charts $(CLUSTER_NAME) --install --values charts/values.yaml --debug --atomic --create-namespace --timeout 8m0s --namespace $(CLUSTER_NAMESPACE)
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Helm start command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run helm stop command.
.PHONY: helm-stop
helm-stop:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running helm-stop command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(HELM_CMD) uninstall $(CLUSTER_NAME) --namespace $(CLUSTER_NAMESPACE)
	$(AT)echo

# Run helm delete command.
.PHONY: helm-delete
helm-delete:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running helm-delete command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(HELM_CMD) delete --purge $(CLUSTER_NAME) --namespace $(CLUSTER_NAMESPACE)
	$(AT)echo

# Run helm package command.
.PHONY: helm-package
helm-package:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running helm-package command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)mkdir -p $(CHART_RELEASE_DIR)/charts
	$(AT)$(HELM_CMD) package charts --dependency-update --destination $(CHART_RELEASE_DIR)/charts
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Helm packages build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run helm dev command.
.PHONY: helm-dev
helm-dev: clean helm-lint helm-package

# Run okteto build command.
.PHONY: okteto
okteto:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running okteto-build command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(OKTETO_CMD) build -t $(DOCKER_HUB_IMAGE_NAME) .
	$(AT)$(OKTETO_CMD) build -t $(OKTETO_IMAGE_NAME) .
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Okteto images build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run python local pip install command.
.PHONY: python-install-pip
python-install-pip:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running install-pip command locally.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)wget $(WGET_OPTS) https://bootstrap.pypa.io/get-pip.py -O $(TMPDIR)/get-pip.py
	$(AT)$(PYTHON_CMD) $(TMPDIR)/get-pip.py
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Pip installed.$(COLOR_NORMAL)"
	$(AT)echo

# Run python local install command.
.PHONY: python-install
python-install: python-install-pip
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running pip-install command locally.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(PYTHON_CMD) -m pip install $(PIP_BUILD_OPTS) -r ./requirements/local.hash $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Python dependencies installation finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run python local build command.
.PHONY: python-build
python-build: python-install
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running mkdocs-build command locally.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(PYTHON_CMD) -m mkdocs build $(MKDOCS_BUILD_OPTS) $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Python documentation build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run python local run command.
.PHONY: python-run
python-run: python-build
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running mkdocs-serve command locally.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)$(PYTHON_CMD) -m mkdocs serve $(MKDOCS_SERVE_OPTS) $@

# Run python local freeze command.
.PHONY: python-local-freeze
python-local-freeze:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running python dependencies freeze locally.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)$(PYTHON_CMD) -m pip freeze $(PIP_OPTS) -r ./docs/requirements.txt $@ > ./docs/requirements_frozen.txt
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Python dependencies local freeze finished.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)exit

# Run python venv install command.
.PHONY: python-venv-install
python-venv-install: _venv
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running pip-install command in venv.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(VENV_PYTHON) -m pip install $(PIP_BUILD_OPTS) -r ./docs/requirements.txt $@
	$(AT)echo
  $(AT)echo "$(COLOR_RED)Python dependencies installation finished. The sources are in $(VENV_NAME) directory.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)exit

# Run python venv build command.
.PHONY: python-venv-build
python-venv-build: python-venv-install
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running mkdocs-build command in venv.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(VENV_PYTHON) -m mkdocs build $(MKDOCS_BUILD_OPTS) $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Python dependencies build finished. The source pages are in $(VENV_NAME) directory.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)exit

# Run python venv run command.
.PHONY: python-venv-run
python-venv-run: python-venv-build
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running mkdocs-serve command in venv.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(VENV_PYTHON) -m mkdocs serve $(MKDOCS_SERVE_OPTS) $@

# Run github pages deploy command.
.PHONY: gh-pages
gh-pages:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running mkdocs gh-deploy command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(PYTHON_CMD) -m mkdocs gh-deploy $(MKDOCS_DEPLOY_OPTS) $@
	$(AT)echo
	$(AT)echo "$(COLOR_RED)GitHub pages generated.$(COLOR_NORMAL)"
	$(AT)echo

# Run npm install command.
.PHONY: deps
deps:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running npm-install command locally.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(NPM_CMD) install
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Install finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run npm all command.
.PHONY: all
all:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running npm-all command locally.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(NPM_CMD) run all
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git diff command.
.PHONY: git-diff
git-diff:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-diff command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(GIT_CMD) diff --diff-filter=d --name-only
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git diff command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git authors command.
.PHONY: git-authors
git-authors:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-authors command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)find . -name ".git" -type d -exec $(GIT_CMD) --git-dir={} --work-tree="$(PWD)"/{} config --get remote.origin.url \; -exec $(GIT_CMD) --git-dir={} --work-tree="$(PWD)"/{} --no-pager shortlog -sn \;
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git authors command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git pull command.
.PHONY: git-pull
git-pull:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-pull command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)find . -name ".git" -type d | xargs -P10 -I{} $(GIT_CMD) --git-dir={} --work-tree="$(PWD)"/{} pull origin master
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git pull command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git branch command.
.PHONY: git-branch
git-branch:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-branch command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(GIT_CMD) for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git branch command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git merge command.
.PHONY: git-merge
git-merge:
	$(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-merge command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(GIT_CMD) log $(shell git merge-base --octopus $(shell git log -1 --merges --pretty=format:%P))..$(shell git log -1 --merges --pretty=format:%H) --pretty=format:%s
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git merge command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git open command.
.PHONY: git-open
git-open:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-open command.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)open $(shell $(GIT_CMD) remote -v | awk "/fetch/{print $2}" | sed -Ee "s#(git@|git://)#http://#" -e "s@com:@com/@" | head -n1 | grep -Eo 'https?://[^ >]+')
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git open command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git log command.
.PHONY: git-log
git-log:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-log command.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)$(GIT_CMD) log \
      --decorate \
      --date="short" \
      --graph \
      --color \
      --pretty="format:%C(yellow)%h%C(reset) %ad%C(red)%d%C(reset) %C(bold normal)%s%C(reset) %G? %C(cyan)[%an]%C(reset)" \
      $(shell $(GIT_CMD) log --pretty=format:'%h' -n 6 | tail -1)..HEAD \
    | sed 's/ N / /g' \
    | sed 's/ G / 🔑  /g'
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git log command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git log command.
.PHONY: git-changelog
git-changelog: release
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-changelog command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(GIT_CMD) log $(shell $(GIT_CMD) tag | tail -n1)..HEAD --no-merges --format=%B > changelog
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git changelog command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run install link checker command.
.PHONY: install-link-checker
install-link-checker:
	$(AT)[ -f $(SCRIPT_DIR)/$(HTMLTEST) ] || curl https://htmltest.wjdp.uk -o $(SCRIPT_DIR)/$(HTMLTEST)

# Run setup link checker command.
.PHONY: setup-link-checker
setup-link-checker: install-link-checker
	$(AT)chmod +x $(SCRIPT_DIR)/$(HTMLTEST)
	$(AT)$(SCRIPT_DIR)/$(HTMLTEST) -d -b $(SCRIPT_DIR)/bin

# Run run link checker command.
.PHONY: run-link-checker
run-link-checker: setup-link-checker
	$(AT)chmod +x $(SCRIPT_DIR)/bin/$(HTMLTEST)
	$(AT)$(SCRIPT_DIR)/bin/$(HTMLTEST) $(HTMLTEST_OPTS)

# Run check links command.
.PHONY: check-links
check-links: install-link-checker setup-link-checker run-link-checker

# Run docker graph command.
.PHONY: docker-graph
docker-graph:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-graph command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) run \
		--platform=linux/amd64 \
		--rm \
    $DOCKER_OPTS \
		--user $(SYS_USER_GROUP) \
		--workdir /workspace \
		--volume "$(PWD)/distribution/docker-images":/workspace \
		$(if $(findstring true,$(VERBOSE)),,--quiet) \
		ghcr.io/patrickhoefler/dockerfilegraph \
		$(SAVE_LOG)
	$(AT)echo

# Run docker lint command.
.PHONY: docker-lint
docker-lint:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-lint command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) run \
		--platform=linux/amd64 \
		--rm \
    $DOCKER_OPTS \
		--user $(SYS_USER_GROUP) \
		--volume "$(PWD):/tmp/lint" \
		$(if $(findstring true,$(VERBOSE)),,--quiet) \
		--env RUN_LOCAL=true \
		--env LINTER_RULES_PATH=/ \
		github/super-linter \
		$(SAVE_LOG)
	$(AT)echo

# Run docker syft command.
.PHONY: docker-syft
docker-syft:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-syft command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) run \
		--platform=linux/amd64 \
		--rm \
    $DOCKER_OPTS \
		--user $(SYS_USER_GROUP) \
		--volume "$(PWD)/config/config.json":/config/config.json \
		$(if $(findstring true,$(VERBOSE)),,--quiet) \
  	--env "DOCKER_CONFIG=/config" \
  	anchore/syft:latest \
  	"$(IMAGE_NAME)" \
  	$(SAVE_LOG)
	$(AT)echo

# Run git zip archive command.
.PHONY: git-zip
git-zip:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-zip archive command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(GIT_CMD) archive -o $(basename $PWD).zip HEAD
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git zip-archive command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git tgz archive command.
.PHONY: git-tgz
git-tgz:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running git-tgz archive command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(GIT_CMD) archive -o $(basename $PWD).tgz HEAD
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Git tgz-archive command finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run docker clean images command.
.PHONY: docker-clean-images
docker-clean-images:
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-clean images command.$(COLOR_NORMAL)"
  $(AT)echo
	echo "Cleaning images \n========================================== ";
	for image in `$(DOCKER_CMD) images -qf "label=$(DOCKER_IMAGE_NAME)"`; do \
	    echo "Removing image $${image} \n==========================================\n " ; \
        $(DOCKER_CMD) rmi -f $${image} || exit 1 ; \
    done
	$(AT)echo
	$(AT)echo "$(COLOR_RED)Docker clean images command finished.$(COLOR_NORMAL)"
	$(AT)echo

.PHONY: kcov
kcov: ## Run kcov
  $(AT)echo
	$(AT)echo "$(COLOR_RED)🌟 Running docker-kcov command.$(COLOR_NORMAL)"
  $(AT)echo
	$(AT)$(DOCKER_CMD) run \
	  --rm $(DOCKER_FLAGS) \
		--user $(SYS_USER_GROUP) \
		--volume "$(PWD)":/workspace \
		-w="/workspace" \
		kcov/kcov \
		kcov \
		--bash-parse-files-in-dir=/workspace \
		--clean \
		--exclude-pattern=.coverage,.git \
		--include-pattern=.sh \
		$(SAVE_LOG)
	$(AT)echo

.PHONY: info
info: ## Gather information about the runtime environment
	$(AT)echo "whoami: $$(whoami)"; \
	$(AT)echo "pwd: $$(pwd)"; \
	$(AT)echo "ls -ahl: $$(ls -ahl)"; \
	$(AT)$(DOCKER_CMD) images; \
	$(AT)$(DOCKER_CMD) ps

# printvars prints all the variables currently defined in our
# Makefiles. Alternatively, if a non-empty VARS variable is passed,
# only the variables matching the make pattern passed in VARS are
# displayed.
.PHONY: printvars
printvars:
	$(AT):
	$(foreach V, \
		$(sort $(filter $(VARS),$(.VARIABLES))), \
		$(if $(filter-out environment% default automatic, \
				$(origin $V)), \
		$(if $(QUOTED_VARS),\
			$(info $V='$(subst ','\'',$(if $(RAW_VARS),$(value $V),$($V)))'), \
			$(info $V=$(if $(RAW_VARS),$(value $V),$($V))))))
