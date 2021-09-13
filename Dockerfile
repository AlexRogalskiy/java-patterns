##
## ---- Base stage ----
## docker build -t styled-java-patterns --build-arg IMAGE_SOURCE=node --build-arg IMAGE_TAG=12-buster .
##
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

ARG NAME="java-patterns"
ARG VERSION="$(git describe --abbrev=0 --tag)"
ARG PACKAGE="AlexRogalskiy/java-patterns"
ARG DESCRIPTION="Java Design Patterns"

ARG LC_ALL="en_US.UTF-8"
ARG BUILD_DATE="$(date -u +\"%Y-%m-%dT%H:%M:%SZ\")"
ARG VCS_REF="$(git rev-parse --short HEAD)"

ARG APP_DIR="/usr/src/app"
ARG DATA_DIR="/usr/src/data"
ARG TEMP_DIR="${TEMP_DIR:-/tmp}"

ARG INSTALL_PACKAGES="git curl tini dos2unix locales"

## setup image labels
LABEL "name"="$NAME"
LABEL "version"="$VERSION"
LABEL "description"="$DESCRIPTION"

LABEL "com.github.repository"="https://github.com/${PACKAGE}"
LABEL "com.github.homepage"="https://github.com/${PACKAGE}"
LABEL "com.github.documentation"="https://github.com/${PACKAGE}/blob/master/README.md"
LABEL "com.github.maintainer"="Sensiblemetrics, Inc. <hello@sensiblemetrics.io> (https://sensiblemetrics.io)"

LABEL "com.github.version"="$VERSION"
LABEL "com.github.build-date"="$BUILD_DATE"
LABEL "com.github.vcs-ref"="$VCS_REF"

LABEL "com.github.name"="$NAME"
LABEL "com.github.description"="$DESCRIPTION"

## setup environment variables
ENV PYTHON_VERSION $PYTHON_VERSION

ENV APP_DIR=$APP_DIR \
    DATA_DIR=$DATA_DIR \
    TEMP_DIR=$TEMP_DIR

ENV TZ=UTC \
    LANGUAGE=en_US:en \
    LC_ALL=$LC_ALL \
    LC_CTYPE=$LC_ALL \
    LANG=$LC_ALL \
    PYTHONIOENCODING=UTF-8 \
    PYTHONLEGACYWINDOWSSTDIO=UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    NPM_CONFIG_LOGLEVEL=error \
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

## mount volumes
VOLUME ["$APP_DIR", "$DATA_DIR", "$TEMP_DIR"]

## create working directory
WORKDIR $APP_DIR

## install dependencies
RUN echo "**** Installing build packages ****"
## RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends $INSTALL_PACKAGES \
    && apt-get autoclean \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

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
RUN echo "npm version: $(npm --version)"
RUN echo "node version: $(node --version | awk -F. '{print $1}')"
RUN echo "python version: $(python3 --version)"

## setup entrypoint
ENTRYPOINT [ "/usr/bin/tini", "--" ]

## remove cache
RUN echo "**** Cleaning cache ****"

RUN apt-get remove -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev g++
RUN rm -rf /var/cache/apt/* /tmp/* /var/tmp/*

## copy project files
COPY package.json .
COPY ./docs/requirements.txt .

##
## ---- Python Dependencies stage ----
##
FROM base AS python-dependencies

## setup python dependencies stage
RUN echo "**** Installing python modules stage ****"

RUN /usr/bin/python3.8 -m pip install --upgrade setuptools && \
    /usr/bin/python3.8 -m pip install --upgrade pip && \
    /usr/bin/python3.8 -m pip install -r requirements.txt

## remove cache
RUN echo "**** Cleaning python cache ****"

RUN rm -rf ~/.cache/pip

##
## ---- Node Dependencies stage ----
##
FROM base AS node-dependencies

## setup node modules stage
RUN echo "**** Installing node modules stage ****"

## update npm settings
RUN npm set progress=false && npm config set depth 0

## install only <production> node_modules
## RUN npm install --no-audit --only=prod

## copy production node_modules aside
## RUN cp -R node_modules prod_node_modules

## install node_modules, including 'devDependencies'
RUN npm install --no-audit

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
#COPY --from=node-dependencies ${APP_DIR}/prod_node_modules ./node_modules
COPY --from=node-dependencies /usr/local/lib/node_modules ./node_modules
COPY --from=node-dependencies ${APP_DIR}/node_modules ./node_modules

## copy source files
COPY . ./

## run format checking & linting
RUN npm run check:all
RUN npm run test:all

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
COPY --from=node-dependencies /usr/local/lib/node_modules ./node_modules
COPY --from=node-dependencies ${APP_DIR}/node_modules ./node_modules
COPY --from=python-dependencies /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

## copy app sources
COPY . ./

## setup user
USER $USER

## expose port
EXPOSE 8000

## define cmd
CMD [ "/usr/bin/python3.8", "-m", "mkdocs", "serve", "--verbose", "--dirtyreload", "--dev-addr=0.0.0.0:8000" ]
## CMD [ "mkdocs", "serve", "--verbose", "--dirtyreload", "-a", "0.0.0.0:8000" ]
