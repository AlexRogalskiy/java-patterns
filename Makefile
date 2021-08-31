# Since we rely on paths relative to the makefile location, abort if make isn't being run from there.
$(if $(findstring /,$(MAKEFILE_LIST)),$(error Please only invoke this makefile from the directory it resides in))

IMAGE ?= styled-java-patterns
TAG ?= latest

UTILS := docker tilt
# Make sure that all required utilities can be located.
UTIL_CHECK := $(or $(shell which $(UTILS) >/dev/null && echo 'ok'),$(error Did you forget to install `docker` and `tilt` after cloning the repo? At least one of the required supporting utilities not found: $(UTILS)))
DIRS := $(shell ls -d -- */ | grep -v public)

# Default target (by virtue of being the first non '.'-prefixed in the file).
.PHONY: _no-target-specified
_no-target-specified:
	$(error Please specify the target to make - `make list` shows targets)

# Lists all targets defined in this makefile.
.PHONY: list
list:
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | command grep -v -e '^[^[:alnum:]]' -e '^$@$$command ' | sort

# Lists all dirs (except `public`).
.PHONY: dirs
dirs:
	echo "$(DIRS)"

# Ensures that the git workspace is clean.
.PHONY: _ensure-clean
_ensure-clean:
	@[ -z "$$((git status --porcelain --untracked-files=no || echo err) | command grep -v 'CHANGELOG.md')" ] || { echo "Workspace is not clean; please commit changes first." >&2; exit 2; }

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
