## Setting base OS layer
## docker build -t container_tag --build-arg IMAGE_SOURCE=node IMAGE_TAG=12-buster .
ARG IMAGE_SOURCE=node
ARG IMAGE_TAG=12-buster

## Setting base image
FROM ${IMAGE_SOURCE}:${IMAGE_TAG}

## Setting argument variables
ARG PYTHON_VERSION=3.8.2

## User with uid/gid
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

## Working directories
ARG APP_DIR="/usr/src/app"
ARG DATA_DIR="/usr/src/data"

## Dependencies
ARG PACKAGES="git curl tini dos2unix locales"

## General metadata
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

## Setting environment variables
ENV PYTHON_VERSION $PYTHON_VERSION

ENV APP_DIR=$APP_DIR \
    DATA_DIR=$DATA_DIR

# System-level base config
ENV TZ=UTC \
    LANGUAGE=en_US:en \
    LC_ALL=$LC_ALL \
    LANG=$LC_ALL \
    PYTHONIOENCODING=UTF-8 \
    PYTHONLEGACYWINDOWSSTDIO=UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

ENV USER=${USER:-'cukebot'} \
    UID=${UID:-5000} \
    GID=${GID:-10000}

ENV npm_config_loglevel=error
ENV IN_DOCKER=True

## Mounting volumes
VOLUME ["$APP_DIR"]

## Creating work directory
WORKDIR $APP_DIR

# Create a cukebot user. Some tools (Bundler, npm publish) don't work properly
# when run as root
RUN addgroup --gid "$GID" "$USER" || exit 0
RUN adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --uid "$UID" \
    --shell /bin/bash \
    "$USER" \
    || exit 0

## Installing dependencies
RUN echo "**** Installing build packages ****"
RUN apt-get update \
    && apt-get install --assume-yes --no-install-recommends $PACKAGES \
    && apt-get autoclean \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

## Installing python
RUN echo "**** Installing Python ****"
RUN cd /tmp && curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -xvf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j 4 && \
    make altinstall

## Copying source files
COPY . ./

## Installing python dependencies
## RUN pip3.8 install --no-cache-dir -r ./docs/requirements.txt --quiet
RUN echo "**** Installing Python modules ****"
RUN pip3.8 install --upgrade pip --quiet

RUN pip3.8 install mkdocs --no-cache-dir --quiet
RUN pip3.8 install mkdocs-material --no-cache-dir --quiet
RUN pip3.8 install pygments --no-cache-dir --quiet
RUN pip3.8 install markdown --no-cache-dir --quiet
RUN pip3.8 install markdown-include --no-cache-dir --quiet
RUN pip3.8 install markdown-checklist --no-cache-dir --quiet
RUN pip3.8 install fontawesome_markdown --no-cache-dir --quiet
RUN pip3.8 install mkdocs-redirects --no-cache-dir --quiet
RUN pip3.8 install mkdocs-material-extensions --no-cache-dir --quiet
RUN pip3.8 install mkdocs-techdocs-core --no-cache-dir --quiet
RUN pip3.8 install mkdocs-git-revision-date-localized-plugin --no-cache-dir --quiet
RUN pip3.8 install mkdocs-awesome-pages-plugin --no-cache-dir --quiet
RUN pip3.8 install mdx_truly_sane_lists --no-cache-dir --quiet
RUN pip3.8 install smarty --no-cache-dir --quiet
RUN pip3.8 install dumb-init --no-cache-dir --quiet
RUN pip3.8 install mkdocs-include-markdown-plugin --no-cache-dir --quiet
#RUN pip3.8 install mkdocs_pymdownx_material_extras --no-cache-dir --quiet
RUN pip3.8 install click-man --no-cache-dir --quiet
## click-man --target path/to/man/pages mkdocs
RUN pip3.8 install cookiecutter --no-cache-dir --quiet

## Removing unnecessary dependencies
RUN echo "**** Cleaning Up cache ****"
RUN apt remove -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev g++
RUN rm -rf /var/cache/apt/* /tmp/Python-${PYTHON_VERSION}

## Show versions
RUN echo "NPM version: $(npm --version)"
RUN echo "NODE version: $(node --version | awk -F. '{print \"$1\"}')"
RUN echo "PYTHON version: $(python3 --version)"

## Install node dependencies
RUN echo "**** Installing project packages ****"
RUN npm install

## Run format checking & linting
RUN npm run test:all

## Setting volumes
VOLUME /tmp

## Setting user
USER $USER

## Expose port
EXPOSE 8000

## Running package bundle
ENTRYPOINT [ "/usr/bin/tini", "--", "/bin/sh", "-c", "mkdocs" ]
#ENTRYPOINT ["mkdocs"]
CMD ["serve", "--verbose", "--dirtyreload", "--dev-addr=0.0.0.0:8000"]
#CMD ["mkdocs", "serve", "--verbose", "--dirtyreload", "-a", "0.0.0.0:8000"]
