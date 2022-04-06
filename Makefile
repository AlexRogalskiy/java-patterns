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
PYTHON_CMD 						:= $(shell command -v python3 2> /dev/null)
# SED_CMD stores stream editor binary
SED_CMD 							:= $(shell command -v sed 2> /dev/null || type -p sed)
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
# GIT_CMD stores git binary
GIT_CMD 							:= $(shell command -v git 2> /dev/null || type -p helm)

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

# WGET_OPTS stores wget options
WGET_OPTS 						:= --no-check-certificate
# PIP_BUILD_OPTS stores pip build options
PIP_BUILD_OPTS		 		:= --disable-pip-version-check --no-cache-dir --no-compile --prefer-binary
# PIP_BUILD_OPTS stores mkdocs build options
MKDOCS_BUILD_OPTS 		:= --clean --strict --verbose --config-file mkdocs.yml
# PIP_BUILD_OPTS stores mkdocs deploy options
MKDOCS_DEPLOY_OPTS 		:= --verbose --clean --force --remote-branch gh-pages
# PIP_BUILD_OPTS stores mkdocs serve options
MKDOCS_SERVE_OPTS 		:= --verbose --dirtyreload --dev-addr=0.0.0.0:8000 --config-file mkdocs.yml
# HTMLTEST stores htmltest binary
HTMLTEST 							:= htmltest
# HTMLTEST_OPTS stores htmltest binary arguments
HTMLTEST_OPTS					:= --skip-external --conf .htmltest.yml

# CHART_RELEASE_DIR stores chart release folder
CHART_RELEASE_DIR 		:= release
# GITHUB_PAGES_DIR stores github pages folder
GITHUB_PAGES_DIR 			:= site
# HTMLTEST_DIR stores htmltest directory
HTMLTEST_DIR					:= scripts

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
VARS += NPM_CMD
VARS += DOCKER_DIR
VARS += VERBOSE

################################################################################
# Targets                                                               		   #
################################################################################

# Run all by default when "make" is invoked.
.DEFAULT_GOAL := help

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
	$(AT)echo -e "$(COLOR_RED)Virtual env created. The source pages are in $(VENV_NAME) directory.$(COLOR_NORMAL)"
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
	$(AT)echo "$(shell ls -ad -- */)"
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Directory list finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run version command.
.PHONY: versions
versions:
	$(AT)echo
	$(AT)$(DOCKER_CMD) --version
	$(AT)echo
	$(AT)$(TILT_CMD) version
	$(AT)echo
	$(AT)$(HELM_CMD) version
	$(AT)echo
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Versions list finished.$(COLOR_NORMAL)"
	$(AT)echo

# Clean removes all temporary files.
.PHONY: clean
clean:
	$(AT)rm -rf $(TMP_BASE)
	$(AT)rm -rf $(CHART_RELEASE_DIR)
	$(AT)rm -rf $(GITHUB_PAGES_DIR)
	$(AT)rm -rf $(VENV_NAME)
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Clean finished.$(COLOR_NORMAL)"
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

# Run docker scan command.
.PHONY: docker-scan
docker-scan:
	$(DOCKER_CMD) scan --json --group-issues --dependency-tree -f Dockerfile "$(IMAGE_NAME)"

# Run docker table command.
.PHONY: docker-table
docker-table:
	$(DOCKER_CMD) ps --format "table {{.Image}}\t{{.Ports}}\t{{.Names}}"

# Run docker code lint command.
.PHONY: docker-code-lint
docker-code-lint:
	$(DOCKER_CMD) run -it \
		--platform=linux/amd64 \
		--rm \
		--ulimit memlock=-1:-1 \
		--user $$(id -u):$$(id -g) \
		--volume $(GIT_ROOT_DIR)/:/data/project/ \
		-p 8080:8080 \
		jetbrains/qodana-jvm-community --show-report

# Run docker clean command.
.PHONY: docker-clean
docker-clean: docker-stop docker-remove

# Run docker remove container command.
.PHONY: docker-remove
docker-remove:
	$(DOCKER_CMD) container rm --force "$(DOCKER_IMAGE_NAME)" > /dev/null

# Run docker remove all images command.
.PHONY: docker-remove-all
docker-remove-all:
	$(DOCKER_CMD) images | grep $(DOCKER_IMAGE_NAME) | awk '{print $3}' | xargs docker rmi -f

# Run docker build command.
.PHONY: docker-build
docker-build: _ensure-docker-tag
	$(AT)chmod +x $(SCRIPT_DIR)/docker-build.sh
	$(SCRIPT_DIR)/docker-build.sh $(DOCKER_TAG)

# Run docker rebuild command.
.PHONY: docker-rebuild
docker-rebuild: _ensure-docker-tag
	$(AT)chmod +x $(SCRIPT_DIR)/docker-rebuild.sh
	$(SCRIPT_DIR)/docker-rebuild.sh $(DOCKER_TAG)

# Run docker start command.
.PHONY: docker-start
docker-start:
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(SCRIPT_DIR)/docker-compose.sh start

# Run docker stop command.
.PHONY: docker-stop
docker-stop:
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(SCRIPT_DIR)/docker-compose.sh stop

# Run docker logs command.
.PHONY: docker-logs
docker-logs:
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(SCRIPT_DIR)/docker-compose.sh logs

# Run docker ps command.
.PHONY: docker-ps
docker-ps:
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(SCRIPT_DIR)/docker-compose.sh ps

# Run docker pull command.
.PHONY: docker-pull
docker-pull:
	$(AT)chmod +x $(SCRIPT_DIR)/docker-compose.sh
	$(SCRIPT_DIR)/docker-compose.sh pull

# Run tilt start command.
.PHONY: tilt-start
tilt-start:
	$(AT)$(TILT_CMD) up

# Run tilt stop command.
.PHONY: tilt-stop
tilt-stop:
	$(AT)$(TILT_CMD) down --delete-namespaces

# Run skaffold deploy command.
.PHONY: skaffold-start
skaffold-start:
	$(AT)$(SKAFFOLD_CMD) dev --filename='skaffold.docker.yaml' --no-prune=true --cache-artifacts=true

# Run skaffold destroy command.
.PHONY: skaffold-stop
skaffold-stop:
	$(AT)$(SKAFFOLD_CMD) delete --filename='skaffold.docker.yaml'

# Run helm lint command.
.PHONY: helm-lint
helm-lint:
	$(AT)$(HELM_CMD) lint charts --values charts/values.yaml

# Run helm start command.
.PHONY: helm-start
helm-start:
	$(AT)$(HELM_CMD) upgrade --install $(CLUSTER_NAME) -f charts/values.yaml --create-namespace --namespace $(CLUSTER_NAMESPACE) charts

# Run helm stop command.
.PHONY: helm-stop
helm-stop:
	$(AT)$(HELM_CMD) uninstall $(CLUSTER_NAME) --namespace $(CLUSTER_NAMESPACE)

# Run helm package command.
.PHONY: helm-package
helm-package:
	$(AT)mkdir -p $(CHART_RELEASE_DIR)/charts
	$(AT)$(HELM_CMD) package charts --dependency-update --destination $(CHART_RELEASE_DIR)/charts
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Helm packages build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run helm dev command.
.PHONY: helm-dev
helm-dev: clean helm-lint helm-package

# Run okteto build command.
.PHONY: okteto
okteto:
	$(AT)okteto build -t $(DOCKER_HUB_IMAGE_NAME) .
	$(AT)okteto build -t $(OKTETO_IMAGE_NAME) .
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Okteto images build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Install pip command.
.PHONY: install-pip
install-pip:
	$(AT)wget $(WGET_OPTS) https://bootstrap.pypa.io/get-pip.py -O $(TMPDIR)/get-pip.py
	$(AT)$(PYTHON_CMD) $(TMPDIR)/get-pip.py
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Pip installed.$(COLOR_NORMAL)"
	$(AT)echo

# Run local build command.
.PHONY: local-build
local-build:
	$(AT)$(PYTHON_CMD) -m pip install $(PIP_BUILD_OPTS) -r ./docs/requirements.txt
	$(AT)$(PYTHON_CMD) -m mkdocs build $(MKDOCS_BUILD_OPTS)
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Python documentation build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run local run command.
.PHONY: local-run
local-run: local-build
	$(AT)$(PYTHON_CMD) -m mkdocs serve $(MKDOCS_SERVE_OPTS)

# Run venv build command.
.PHONY: venv-build
venv-build: _venv
	$(AT)$(VENV_PYTHON) -m pip install $(PIP_BUILD_OPTS) -r ./docs/requirements.txt
	$(AT)$(VENV_PYTHON) -m mkdocs build $(MKDOCS_BUILD_OPTS)
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Build finished. The source pages are in $(VENV_NAME) directory.$(COLOR_NORMAL)"
	$(AT)echo
	$(AT)exit

# Run venv run command.
.PHONY: venv-run
venv-run: venv-build
	$(AT)$(VENV_PYTHON) -m mkdocs serve $(MKDOCS_SERVE_OPTS)

# Run github pages deploy command.
.PHONY: gh-pages
gh-pages:
	$(AT)$(PYTHON_CMD) -m mkdocs gh-deploy $(MKDOCS_DEPLOY_OPTS)
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)GitHub pages generated.$(COLOR_NORMAL)"
	$(AT)echo

# Run npm install command.
.PHONY: deps
deps:
	$(AT)$(NPM_CMD) install
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Install finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run npm all command.
.PHONY: all
all:
	$(AT)$(NPM_CMD) run all
	$(AT)echo
	$(AT)echo -e "$(COLOR_RED)Build finished.$(COLOR_NORMAL)"
	$(AT)echo

# Run git diff command.
.PHONY: diff
diff:
	$(AT)$(GIT_CMD) diff --diff-filter=d --name-only

# Run git authors command.
.PHONY: git-authors
git-authors:
	$(AT)echo
	$(AT)find . -name ".git" -type d -exec $(GIT_CMD) --git-dir={} --work-tree="$(PWD)"/{} config --get remote.origin.url \; -exec $(GIT_CMD) --git-dir={} --work-tree="$(PWD)"/{} --no-pager shortlog -sn \;
	$(AT)echo

# Run git pull command.
.PHONY: git-pull
git-pull:
	$(AT)echo
	$(AT)find . -name ".git" -type d | xargs -P10 -I{} $(GIT_CMD) --git-dir={} --work-tree="$(PWD)"/{} pull origin master
	$(AT)echo

# Run git log command.
.PHONY: git-changelog
git-changelog: release
	$(AT)echo "🌟 Running git changelog command"
	$(AT)$(GIT_CMD) log $(shell $(GIT_CMD) tag | tail -n1)..HEAD --no-merges --format=%B > changelog

# Run install link checker command.
.PHONY: install-link-checker
install-link-checker:
	$(AT)[ -f $(HTMLTEST_DIR)/$(HTMLTEST) ] || curl https://htmltest.wjdp.uk -o $(HTMLTEST_DIR)/$(HTMLTEST)

# Run setup link checker command.
.PHONY: setup-link-checker
setup-link-checker: install-link-checker
	$(AT)chmod +x $(HTMLTEST_DIR)/$(HTMLTEST)
	$(HTMLTEST_DIR)/$(HTMLTEST) -d -b $(HTMLTEST_DIR)/bin

# Run run link checker command.
.PHONY: run-link-checker
run-link-checker: setup-link-checker
	$(AT)chmod +x $(HTMLTEST_DIR)/bin/$(HTMLTEST)
	$(HTMLTEST_DIR)/bin/$(HTMLTEST) $(HTMLTEST_OPTS)

# Run check links command.
.PHONY: check-links
check-links: install-link-checker setup-link-checker run-link-checker

# Run docker graph command.
.PHONY: docker-graph
docker-graph:
	$(AT)$(DOCKER_CMD) run \
		--platform=linux/amd64 \
		--rm \
		--user $(USER_ID):$(GROUP_ID) \
		--workdir /workspace \
		--volume "$(PWD)/distribution/docker-images":/workspace \
		ghcr.io/patrickhoefler/dockerfilegraph

# Run lint command.
.PHONY: lint
lint:
	$(AT)$(DOCKER_CMD) run \
		--platform=linux/amd64 \
		--rm \
		--user $(USER_ID):$(GROUP_ID) \
		--volume "$(PWD):/tmp/lint" \
		-e RUN_LOCAL=true \
		-e LINTER_RULES_PATH=/ \
		github/super-linter

# Run syft command.
.PHONY: syft
syft:
	$(AT)$(DOCKER_CMD) run \
		--platform=linux/amd64 \
		--rm \
		--user $(USER_ID):$(GROUP_ID) \
		--volume "$(PWD)/config/config.json":/config/config.json \
		$(if $(findstring true,$(VERBOSE)),,--quiet) \
  	-e "DOCKER_CONFIG=/config" \
  	anchore/syft:latest \
  	"$(IMAGE_NAME)"

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

# Run zip archive command.
.PHONY: git-zip
git-zip:
	$(AT)$(GIT_CMD) archive -o $(basename $PWD).zip HEAD

# Run tgz archive command.
.PHONY: git-tgz
git-tgz:
	$(AT)$(GIT_CMD) archive -o $(basename $PWD).tgz HEAD

# Run clean images command.
.PHONY: clean-images
clean-images:
	echo "Cleaning images \n========================================== ";
	for image in `$(DOCKER_CMD) images -qf "label=$(DOCKER_IMAGE_NAME)"`; do \
	    echo "Removing image $${image} \n==========================================\n " ; \
        $(DOCKER_CMD) rmi -f $${image} || exit 1 ; \
    done
