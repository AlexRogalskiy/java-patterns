ifndef __COMMONS_MAKEFILE__

__COMMONS_MAKEFILE__ := included

################################################################################
# Default variables                                                            #
################################################################################

# UID stores user identifier
UID  											:= $(shell id -u)
# GID stores group identifier
GID  											:= $(shell id -g)

# GIT_ROOT_DIR stores git root directory
GIT_ROOT_DIR 							:= $(shell git rev-parse --show-toplevel)
# GIT_COMMIT_MESSAGE stores git commit message
GIT_COMMIT_MESSAGE 				:= $(shell git show -s --format=%s HEAD)
# GIT_COMMIT_AUTHOR_EMAIL stores git commit author email
GIT_COMMIT_AUTHOR_EMAIL 	:= $(shell git show -s --format=%ae)
# GIT_COMMIT_AUTHOR_NAME stores git commit author name
GIT_COMMIT_AUTHOR_NAME 		:= $(shell git show -s --format=%an)
# GIT_COMMIT_TIMESTAMP stores git commit timestamp
GIT_COMMIT_TIMESTAMP 			:= $(shell git show -s --format=%ct)
# GIT_DIRTY_TAG stores dirty git tag
GIT_DIRTY_TAG 						:= $(shell git describe --tags --always --dirty)
# GIT_WORKING_SUFFIX stores git working suffix
GIT_WORKING_SUFFIX        := $(shell if git status --porcelain | grep -qE '^(?:[^?][^ ]|[^ ][^?])\s'; then echo "-WIP"; else echo ""; fi)
# GIT_TAG stores git last tag
GIT_TAG 									:= $(shell git tag -l | grep -E '[0-9]+(.[0-9]+){2}' | sort -t. -k 1,1nr -k 2,2nr -k 3,3nr | head -1)
# GIT_COMMIT_SHA stores git last commit hash
GIT_COMMIT_SHA 						:= $(shell git rev-parse --short=8 --verify HEAD)
# GIT_REMOTE_NAME stores git remote branch name
GIT_REMOTE_NAME						:= $(shell git describe --all --exact-match HEAD)
# GIT_TREE_SHA stores git tree hash
GIT_TREE_SHA 							:= $(shell git hash-object -t tree /dev/null)
# GIT_LOG_COMMIT_TIMESTAMP stores last commit to allow for reproducible builds
GIT_LOG_COMMIT_TIMESTAMP 	:= $(shell git log -1 --date=format:%Y%m%d%H%M --pretty=format:%cd)
# GIT_ORIG_BRANCH stores original git branch name
GIT_ORIG_BRANCH 					:= $(shell git rev-parse --abbrev-ref HEAD | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/,/\&\#44;/g' | sed 's/[\/\-]/\./g')
# GIT_ORIG_TAG stores original git tag name
GIT_ORIG_TAG 							:= $(shell git describe --exact-match --abbrev=0 2>/dev/null | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/,/\&\#44;/g' || echo "")
# GIT_ORIG_VERSION stores original git tag version
GIT_ORIG_VERSION 					:= $(shell (git for-each-ref refs/tags --sort=-taggerdate --format='%(refname)' --count=1 | sed -Ee 's/^refs\/tags\/v|-.*//'))

# GIT_REPO_INFO stores git remote url
GIT_REPO_INFO  						:= $(shell git config --get remote.origin.url)
# GIT_REPO_PREFIX stores git repository prefix
GIT_REPO_PREFIX 					:= $(shell git config --get remote.origin.url | tr ':.' '/'  | rev | cut -d '/' -f 3 | rev)
# GIT_REPO_NAME stores git repository name
GIT_REPO_NAME 						:= $(shell git config --get remote.origin.url | tr ':.' '/'  | rev | cut -d '/' -f 2 | rev)
# GIT_REPO_TAG stores git repository tag
GIT_REPO_TAG              := $(shell echo "${GIT_ORIG_BRANCH//\//-}-$(GIT_COMMIT_SHA):$(GIT_WORKING_SUFFIX)")

# SYS_HOST stores system hostname
SYS_HOST 									:= $(shell hostname | tr '[:upper:]' '[:lower:]')
# SYS_OS stores system operating system
SYS_OS 					  				:= $(shell uname -s | tr '[:upper:]' '[:lower:]')
# SYS_ARCH stores system architecture
SYS_ARCH 									:= $(shell uname -m | sed -e 's/_.*//' | tr '[:upper:]' '[:lower:]' | sed -e 's/x86_64/amd64/' | sed -e 's/aarch64\(_be\)\?/arm64/' | sed -e 's/\(arm\)\(64\)\?.*/\1\2/' | sed -e 's/^\(msys\|mingw\).*/windows/')
# SYS_USER_GROUP stores system user name/group
SYS_USER_GROUP 						:= $(shell echo "$(UID):$(GID)")
# SYS_CPU stores system cpu count
SYS_CPU 									:= $(shell bash $(GIT_ROOT_DIR)/scripts/read_cpus_available.sh)
# SYS_LANGUAGE stores system locale
SYS_LANGUAGE 							:= $(shell locale | egrep "^LANG=" | cut -d= -f2 | cut -d_ -f1 | tr -d '"' | egrep "^[a-z]{2}")

# QUIET stores silent mode
QUIET 										:= $(if $(findstring s,$(filter-out --%,$(MAKEFLAGS))),-q)

# TMP_BASE is the base directory used for TMP.
# Use TMP and not TMP_BASE as the temporary directory.
TMP_BASE 									:= .tmp
# TMP_COVERAGE is where we store code coverage files.
TMP_COVERAGE 							:= $(TMP_BASE)/coverage

# DOCKER_CLI_EXPERIMENTAL stores docker cli experimental option
DOCKER_CLI_EXPERIMENTAL 	:= enabled
# DOCKER_BUILDKIT stores docker BuildKit option
DOCKER_BUILDKIT 					:= 1
# COMPOSE_DOCKER_CLI_BUILD stores docker cli build option
COMPOSE_DOCKER_CLI_BUILD 	:= 1

# WGET_OPTS stores wget options
WGET_OPTS 						    := --no-check-certificate

# CURL_OPTS stores curl options
CURL_OPTS 						    := --silent --show-error --location --fail --retry-connrefused --tlsv1.2 --proto "=https" --retry 3 --retry-delay 0 --retry-max-time 180

# Date/time vars
DATE_TIME_LONG			      := $(shell date +%Y-%m-%d' '%H:%M:%S)
DATE_TIME_SHORT		        := $(shell date +%H:%M:%S)
DATE_TIME					        := $(DATE_TIME_SHORT)

# Color vars
COLOR_BLUE                := $(shell printf "\033[34m")
COLOR_YELLOW              := $(shell printf "\033[33m")
COLOR_RED                 := $(shell printf "\033[31m")
COLOR_GREEN               := $(shell printf "\033[32m")
COLOR_NORMAL              := $(shell printf "\033[0m")

# Status vars
PRINT_INFO		            := echo ${DATE_TIME} ${COLOR_BLUE}[ INFO ]${COLOR_NORMAL}
PRINT_WARN		            := echo ${DATE_TIME} ${COLOR_YELLOW}[ WARN ]${COLOR_NORMAL}
PRINT_ERR			            := echo ${DATE_TIME} ${COLOR_RED}[ ERR ]${COLOR_NORMAL}
PRINT_OK			            := echo ${DATE_TIME} ${COLOR_GREEN}[ OK ]${COLOR_NORMAL}
PRINT_FAIL		            := (echo ${DATE_TIME} ${COLOR_RED}[ FAIL ]${COLOR_NORMAL} && false)

# Symbolic vars
SUCCESS_CHECKMARK         := $(printf '\342\234\224\n' | iconv -f UTF-8)
CROSS_MARK                := $(printf '\342\235\214\n' | iconv -f UTF-8)

################################################################################
# Common variables                                                             #
################################################################################

# Set V=1 on the command line to turn off all suppression. Many trivial
# commands are suppressed with "@", by setting V=1, this will be turned off.
ifeq ($(V),1)
	AT :=
else
	AT := @
endif

# Save running make version since it's clobbered by the make package
RUNNING_MAKE_VERSION := $(MAKE_VERSION)

# Check for minimal make version (note: this check will break at make 10.x)
MIN_MAKE_VERSION = 3.81
ifneq ($(firstword $(sort $(RUNNING_MAKE_VERSION) $(MIN_MAKE_VERSION))),$(MIN_MAKE_VERSION))
	$(error You have make '$(RUNNING_MAKE_VERSION)' installed. GNU make >= $(MIN_MAKE_VERSION) is required)
endif

ifeq ($(GIT_COMMIT),)
  override GIT_COMMIT = $(shell git rev-parse --short HEAD 2> /dev/null || echo "unknown-commit")
endif

ifeq ($(GIT_VERSION),)
  override GIT_VERSION = $(shell git describe --always --abbrev=7 --dirty --tags 2> /dev/null || echo "unknown-version")
endif

ifeq ($(BUILD_TIME),)
  override BUILD_TIME = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ" 2> /dev/null)
endif
ifeq ($(BUILD_TIME),)
  override BUILD_TIME = unknown-buildtime
  $(warning unable to set BUILD_TIME. Set the value manually)
endif

DATE_FMT ?= +'%Y-%m-%dT%H:%M:%SZ'
SOURCE_DATE_EPOCH ?= $(shell git log -1 --pretty=%ct)
ifdef SOURCE_DATE_EPOCH
    override BUILD_DATE = $(shell date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u "$(DATE_FMT)")
else
    override BUILD_DATE = $(shell date "$(DATE_FMT)")
endif

GIT_TREESTATE = "clean"
DIFF = $(shell git diff --quiet >/dev/null 2>&1; if [ $$? -eq 1 ]; then echo "1"; fi)
ifeq ($(DIFF), 1)
    override GIT_TREESTATE = "dirty"
endif

ifeq ($(JAVA_HOME),)
  export JAVA_HOME = $(shell java -cp .)
endif

ifeq ($(SYS_ARCH),x86_64)
  override ARCH_TAG = x64
else
  ifeq ($(findstring arm,$(SYS_ARCH)),arm)
    ifeq ($(findstring 64,$(SYS_ARCH)),64)
      override ARCH_TAG = arm64
    else
      override ARCH_TAG = arm32
    endif
  else
    ifeq ($(findstring aarch64,$(SYS_ARCH)),aarch64)
      override ARCH_TAG = arm64
    else
      ifeq ($(SYS_ARCH),ppc64le)
        override ARCH_TAG = ppc64le
      else
        override ARCH_TAG = x86
      endif
    endif
  endif
endif

ifeq ($(PROFILES),)
  override PROFILES = ci dev release
endif

ifeq ($(UTILS),)
  override UTILS = docker tilt helm
endif

# Output prefix, defaults to local directory if not specified
ifeq ($(PREFIX),)
  override PREFIX = $(shell pwd)
endif

export CONTAINER_TOOL ?= auto
ifeq ($(CONTAINER_TOOL),auto)
	override CONTAINER_TOOL = $(shell docker version >/dev/null 2>&1 && echo docker || echo podman)
endif

export GIT_VERSION_STRATEGY ?= commit_hash
ifdef GIT_ORIG_TAG
	override GIT_DIRTY_TAG = $(GIT_ORIG_TAG)
	override GIT_VERSION_STRATEGY = tag
else
	ifeq (,$(findstring $(GIT_ORIG_BRANCH),master HEAD))
		ifneq (,$(patsubst release-%,,$(GIT_ORIG_BRANCH)))
			override GIT_DIRTY_TAG = $(GIT_ORIG_BRANCH)
			override GIT_VERSION_STRATEGY = branch
		endif
	endif
endif

ifneq ($(VERBOSE),)
  override VERBOSE_FLAG = -v
endif

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += --tty
endif

ifneq ($(strip $(V)),1)
  WGET_OPTS += -o /dev/null
endif

ifdef SYS_CPU
	override DOCKER_CPU_OPTS = --cpu-period="100000" --cpu-quota="$$(( $(SYS_CPU) * 100000 ))"
else
	override DOCKER_CPU_OPTS =
endif

ifeq ($(DOCKER_COMPOSE_OPTS),)
  override DOCKER_COMPOSE_OPTS = --ansi=never
endif

ifeq ($(DOCKER_OPTS),)
  override DOCKER_OPTS = --shm-size=1G
endif

ifdef DOCKER_REGISTRY
	override DOCKER_REGISTRY = $(DOCKER_REGISTRY)/
endif

ifdef DOCKER_ORG
	override DOCKER_ORG = $(DOCKER_ORG)/
endif

ifdef DOCKER_VERSION
	override MUTABLE_DOCKER_VERSION = latest
else
	override DOCKER_VERSION = $(GIT_VERSION)
	override MUTABLE_DOCKER_VERSION = edge
endif

################################################################################
# Common macros                                                               #
################################################################################

# Check the presence of a CLI in the current PATH
check_cli = type "$(1)" >/dev/null 2>&1 || { echo "Error: command '$(1)' required but not found. Exiting." ; exit 1 ; }
#@$(call check_cli,bash)
#@$(call check_cli,git)
#@$(call check_cli,docker)
#@$(call check_cli,curl)
#@$(call check_cli,jq)

################################################################################
# Common functions                                                             #
################################################################################

define print_target
  @$(call print_notice,Building $@...)
endef

define print_notice
  printf "\n\033[93m\033[1m$(1)\033[0m\n"
endef

define print_error
  printf "\n\033[93m\033[1m$(1)\033[0m\n"
endef

################################################################################
# Common targets                                                               #
################################################################################

# Check command exists.
.PHONY: check-%
check-%:
	$(AT)which ${*} > /dev/null || (echo '*** Please install `${*}` ***' && exit 1)

# Check required command exists.
.PHONY: require-%
require-%:
	$(shell command -v $* 2> /dev/null) || $(error Please install `$*` command)

# Check optional variable exists.
.PHONY: check-optional-variable-%
check-optional-variable-%:
	$(AT)[[ "${${*}}" ]] || (echo '*** Variable `${*}` is optional. Make sure you understand how to use it ***')

# Check variable exists.
.PHONY: check-variable-%
check-variable-%:
	$(AT)[[ "${${*}}" ]] || (echo '*** Please define variable `${*}` ***' && exit 1)

# Check file exists.
.PHONY: check-file-%
check-file-%:
	$(eval tag := `echo "${*}" | sed -e "s/-rc.//"`)
	$(eval release_file := "docs/${tag}.md")
	$(AT)test -f ${release_file} || (echo "*** Please define file ${release_file} ***" && exit 1)

# Check build version provided.
.PHONY: _check_version
_check_version:
ifndef BUILD_VERSION
	$(error Please invoke with `make BUILD_VERSION=[version]`)
endif

# Check maven expression provided.
.PHONY: _check_expression
_check_expression:
ifndef MVN_EXPRESSION
	$(error Please invoke with `make MVN_EXPRESSION=[expression]`)
endif

# Check make target provided.
.PHONY: _check_target
_check_target:
ifneq ($(filter $(firstword $(MAKECMDGOALS)),$(PROFILES)),)
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

# Check docker tag provided.
.PHONY: _check_tag
_check_tag:
ifndef DOCKER_TAG
	$(error Please invoke with a tag `make DOCKER_TAG=[ $(PROFILES) ]`)
endif

# Print make environment variables.
.PHONY: _list-env
_list-env:
	$(AT)echo
	$(AT)echo "==========================================";
	$(AT)echo
	$(AT)echo "SYS_HOST="$(SYS_HOST);
	$(AT)echo "SYS_OS="$(SYS_OS);
	$(AT)echo "SYS_ARCH="$(SYS_ARCH);
	$(AT)echo "SYS_USER_GROUP="$(SYS_USER_GROUP);
	$(AT)echo
	$(AT)echo "BUILD_TIME="$(BUILD_TIME);
	$(AT)echo "BUILD_DATE="$(BUILD_DATE);
	$(AT)echo "JAVA_HOME="$(JAVA_HOME);
	$(AT)echo "ARCH_TAG="$(ARCH_TAG);
	$(AT)echo
	$(AT)echo "GIT_ROOT_DIR="$(GIT_ROOT_DIR);
	$(AT)echo "GIT_COMMIT_SHA="$(GIT_COMMIT_SHA);
	$(AT)echo "GIT_COMMIT="$(GIT_COMMIT);
	$(AT)echo "GIT_TREESTATE="$(GIT_TREESTATE);
	$(AT)echo "GIT_ORIG_BRANCH="$(GIT_ORIG_BRANCH);
	$(AT)echo "GIT_ORIG_TAG="$(GIT_ORIG_TAG);
	$(AT)echo "GIT_ORIG_VERSION="$(GIT_ORIG_VERSION);
	$(AT)echo "GIT_REPO_PREFIX="$(GIT_REPO_PREFIX);
	$(AT)echo "GIT_REPO_NAME="$(GIT_REPO_NAME);
	$(AT)echo "GIT_DIRTY_TAG="$(GIT_DIRTY_TAG);
	$(AT)echo "GIT_COMMIT_TIMESTAMP="$(GIT_COMMIT_TIMESTAMP);
	$(AT)echo "GIT_REPO_INFO="$(GIT_REPO_INFO);
	$(AT)echo "GIT_VERSION_STRATEGY="$(GIT_VERSION_STRATEGY);
	$(AT)echo
	$(AT)echo "DOCKER_REGISTRY="$(DOCKER_REGISTRY);
	$(AT)echo "DOCKER_ORG="$(DOCKER_ORG);
	$(AT)echo "DOCKER_VERSION="$(DOCKER_VERSION);
	$(AT)echo "DOCKER_CPU_OPTS="$(DOCKER_CPU_OPTS);
	$(AT)echo "DOCKER_OPTS="$(DOCKER_OPTS);
	$(AT)echo "DOCKER_COMPOSE_OPTS="$(DOCKER_COMPOSE_OPTS);
  $(AT)echo
  $(AT)echo "WGET_OPTS="$(WGET_OPTS);
	$(AT)echo
	$(AT)echo "==========================================";
	$(AT)echo

endif
