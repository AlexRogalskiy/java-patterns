# Available Build Args:
#   IMAGE_SOURCE: source image name
#   IMAGE_TAG: source image tag
#   PYTHON_VERSION: python version
#   USER: shell user
#   UID: user identifier
#   GID: group identifier
#   IMAGE_NAME: image name
#   IMAGE_PACKAGE: image package name
#   IMAGE_DESCRIPTION: image description
#   IMAGE_VENDOR: image vendor
#   IMAGE_URL: image url
#   IMAGE_AUTHORS: image authors
#   IMAGE_LICENSES: image authors
#   IMAGE_DOCUMENTATION: image documentation
#   IMAGE_REVISION: image reversion
#   IMAGE_VERSION: image version
#   IMAGE_BUILD_DATE: image build date
#   APP_DIR: target application directory
#   DATA_DIR: target data directory
#   TEMP_DIR: target temp directory
#   INSTALL_PACKAGES: list of installed packages
##
## ---- Base stage ----
## docker build -t styled-java-patterns --build-arg IMAGE_SOURCE=node --build-arg IMAGE_TAG=12-buster .
##
# syntax=docker/dockerfile:experimental
ARG IMAGE_SOURCE=node
ARG IMAGE_TAG=12-buster

FROM ${IMAGE_SOURCE}:${IMAGE_TAG} AS base

## setup base stage
RUN echo "**** Base stage ****"

## setup image arguments
ARG PYTHON_VERSION=3.8.2

ARG USER
ARG UID
ARG GID

ARG IMAGE_NAME="java-patterns"
ARG IMAGE_PACKAGE="AlexRogalskiy/${IMAGE_NAME}"
ARG IMAGE_DESCRIPTION="Java Design Patterns Documentation"
ARG IMAGE_VENDOR="Sensiblemetrics, Inc. <hello@sensiblemetrics.io> (https://sensiblemetrics.io)"
ARG IMAGE_URL="https://github.com/${IMAGE_PACKAGE}"
ARG IMAGE_AUTHORS="${IMAGE_URL}/blob/master/AUTHORS"
ARG IMAGE_LICENSES="${IMAGE_URL}/blob/master/LICENSE.txt"
ARG IMAGE_DOCUMENTATION="${IMAGE_URL}/blob/master/README.md"
ARG IMAGE_REVISION="$(git rev-parse --short HEAD)"
ARG IMAGE_VERSION="$(git describe --tags --contains --always)"
ARG IMAGE_BUILD_DATE="$(date -u +\"%Y-%m-%dT%H:%M:%SZ\")"

ARG APP_DIR="/usr/src/app"
ARG DATA_DIR="/usr/src/data"
ARG TEMP_DIR="${TEMP_DIR:-/tmp}"

ARG APT_INSTALL_PACKAGES="git curl tini dos2unix locales"
ARG APT_INSTALL_OPTIONS="--assume-yes --no-install-recommends --only-upgrade --allow-downgrades -allow-remove-essential --allow-change-held-packages"

## setup image labels
LABEL "name"="$IMAGE_NAME" \
      "version"="$IMAGE_VERSION" \
      "org.opencontainers.image.title"="$IMAGE_NAME" \
      "org.opencontainers.image.description"="$IMAGE_DESCRIPTION" \
      "org.opencontainers.image.vendor"="$IMAGE_VENDOR" \
      "org.opencontainers.image.url"="$IMAGE_URL" \
      "org.opencontainers.image.authors"="$IMAGE_AUTHORS" \
      "org.opencontainers.image.licenses"="$IMAGE_LICENSES" \
      "org.opencontainers.image.documentation"="$IMAGE_DOCUMENTATION" \
      "org.opencontainers.image.source"="$IMAGE_URL" \
      "org.opencontainers.image.revision"="$IMAGE_REVISION" \
      "org.opencontainers.image.version"="$IMAGE_VERSION" \
      "org.opencontainers.image.created"="$IMAGE_BUILD_DATE"

## setup shell options
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

## setup environment variables
ENV PYTHON_VERSION=$PYTHON_VERSION \
    APP_DIR=$APP_DIR \
    DATA_DIR=$DATA_DIR \
    TEMP_DIR=$TEMP_DIR

ENV DEBIAN_FRONTEND=noninteractive \
    TERM="xterm" \
    PAGER=cat \
    TZ=UTC \
    LC_ALL="en_US.UTF-8" \
    LANG=$LC_ALL \
    LANGUAGE=$LC_ALL \
    LC_CTYPE=$LC_ALL \
    PYTHONIOENCODING=UTF-8 \
    PYTHONLEGACYWINDOWSSTDIO=UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    NPM_CONFIG_LOGLEVEL=error \
    npm_config_update_notifier=false \
    NODE_NO_WARNINGS='1' \
    NODE_TLS_REJECT_UNAUTHORIZED='0' \
    NODE_OPTIONS="--max-old-space-size=8192" \
    IN_DOCKER=True

ENV USER=${USER:-'devbot'} \
    UID=${UID:-5000} \
    GID=${GID:-10000}

## create user
RUN addgroup --gid "$GID" "$USER" || exit 0
RUN adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --uid "$UID" \
    --shell /bin/bash \
    "$USER" \
    || exit 0

# Switch to the runtime user
USER $USER

# Run commands as runtime user
RUN whoami \
    # opt-out of the new security feature, not needed in a CI environment
    && git config --global --add safe.directory '*' \
    && git config --global user.email "support@sensiblemetrics.com" \
    && git config --global user.name "sensiblemetrics"

## mount volumes
VOLUME ["$APP_DIR", "$DATA_DIR", "$TEMP_DIR"]

## create working directory
WORKDIR $APP_DIR

## install dependencies
RUN echo "**** Installing build packages ****"
## RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get -yqq $APT_INSTALL_OPTIONS update \
    && apt-get -yqq $APT_INSTALL_OPTIONS upgrade \
    && apt-get -yqq --force-yes $APT_INSTALL_OPTIONS dist-upgrade \
    && apt-get -yqq $APT_INSTALL_OPTIONS install $APT_INSTALL_PACKAGES 2>&1 > /dev/null \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=${LANG} LANGUAGE=${LANGUAGE} LC_ALL=${LC_ALL} \
    && apt-get -yqq autoclean \
    && apt-get -yqq clean \
    && apt-get -yqq autoremove --purge \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /usr/share/man/* /usr/share/doc/* /usr/share/info/* /usr/share/groff/* /usr/share/lintian/* /usr/share/linda/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/cache/apt/*

## install python
RUN echo "**** Installing Python ****"
RUN cd /tmp && curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -xvf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j 4 && \
    make altinstall && \
    ln -s /usr/local/bin/python3.8 /usr/bin/python3.8

## show versions
RUN echo ">>> npm version: $(npm --version)" \
    && echo ">>> node version: $(node --version | awk -F. '{print $1}')" \
    && echo ">>> python version: $(python3 --version)"

## setup entrypoint
ENTRYPOINT [ "/usr/bin/tini", "--" ]

## remove cache
RUN echo "**** Cleaning packages ****"
RUN apt-get remove -yqq build-essential zlib1g-dev libncurses5-dev libgdbm-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev g++ 2>&1 > /dev/null

## copy project files
COPY ./package.json .
COPY ./docs/requirements.txt .

##
## ---- Python Dependencies stage ----
##
FROM base AS python-dependencies

## setup image arguments
ARG PYTHON_INSTALL_PACKAGES="setuptools pip"
ARG PYTHON_INSTALL_OPTIONS="--no-ansi --upgrade"

## setup python dependencies stage
RUN echo "**** Installing python modules stage ****"

RUN /usr/local/bin/python3.8 -m pip install $PYTHON_INSTALL_OPTIONS $PYTHON_INSTALL_PACKAGES && \
    /usr/local/bin/python3.8 -m pip install $PYTHON_INSTALL_OPTIONS -r requirements.txt

## remove cache
RUN echo "**** Cleaning python cache ****"

RUN rm -rf ~/.cache/pip

##
## ---- Node Dependencies stage ----
##
FROM base AS node-dependencies

## setup image arguments
ARG NPM_INSTALL_OPTIONS="--no-cache --no-audit --ignore-scripts --allow-root --unsafe-perm --no-progress --prefer-offline"

## setup node modules stage
RUN echo "**** Installing node modules stage ****"

## update npm settings
RUN npm config set progress=false \
    && npm config set depth 0 \
    && npm config set package-lock true  \
    && npm config set loglevel error

## install only <production> node_modules
## RUN npm install --no-audit --only=prod

## copy production node_modules aside
## RUN cp -R node_modules prod_node_modules

## install node_modules, including 'devDependencies'
RUN npm install $NPM_INSTALL_OPTIONS --only=dev \
    && npm audit fix --audit-level=critical

## remove cache
RUN echo "**** Cleaning node cache ****"

RUN npm cache clean --force

##
## ---- Test stage ----
##
FROM base AS test

## setup testing stage
RUN echo "**** Testing stage ****"

## copy dependencies
COPY --from=node-dependencies --chown=$USER /usr/local/lib/node_modules ./node_modules

## copy source files
COPY . ./

## run format checking & linting
RUN npm run all

##
## ---- Release stage ----
##
FROM base AS release

## setup release stage
RUN echo "**** Release stage ****"

## setup environment path
ENV PATH=/root/.local:$PATH

## copy dependencies
#COPY --from=node-dependencies ${APP_DIR}/prod_node_modules ./node_modules
COPY --from=node-dependencies --chown=$USER /usr/local/lib/node_modules ./node_modules
COPY --from=python-dependencies --chown=$USER /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

## copy app sources
COPY . ./

## expose port
EXPOSE 8000

## define cmd
CMD [ "/usr/local/bin/python3.8", "-m", "mkdocs", "serve", "--verbose", "--dirtyreload", "--dev-addr=0.0.0.0:8000" ]
## CMD [ "mkdocs", "serve", "--verbose", "--dirtyreload", "-a", "0.0.0.0:8000" ]
