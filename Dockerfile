## Setting image source variables
ARG IMAGE_SOURCE=node
ARG IMAGE_TAG=12-buster

## Setting base image
FROM ${IMAGE_SOURCE}:${IMAGE_TAG}

## Setting argument variables
ARG PYTHON_VERSION=3.8.2

ARG USER="cukebot"
ARG UID=5000
ARG GID=10000

ARG NAME="java-patterns"
ARG VERSION="0.0.0-dev"
ARG DESCRIPTION="Java Design Patterns"

ARG LC_ALL="en_US.UTF-8"
ARG BUILD_DATE="$(git rev-parse --short HEAD)"
ARG VCS_REF="$(date -u +\"%Y-%m-%dT%H:%M:%SZ\")"

ARG APP_DIR="/usr/src/app"
ARG DATA_DIR="/usr/src/data"

## General metadata
LABEL "name"="$NAME"
LABEL "version"="$VERSION"
LABEL "description"="$DESCRIPTION"

LABEL "com.github.repository"="https://github.com/AlexRogalskiy/java-patterns"
LABEL "com.github.homepage"="https://github.com/AlexRogalskiy/java-patterns"
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
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

ENV USER=$USER \
    UID=$UID \
    GID=$GID

## Mounting volumes
VOLUME ["$APP_DIR"]

## Creating work directory
WORKDIR $APP_DIR

# Create a cukebot user. Some tools (Bundler, npm publish) don't work properly
# when run as root
RUN addgroup --gid "$GID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --uid "$UID" \
    --shell /bin/bash \
    "$USER"

## Installing dependencies
RUN apt-get update \
    && apt-get install --assume-yes \
    git \
    curl \
    locales \
    && apt-get clean

## Installing python
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
RUN pip3.8 install --upgrade pip --quiet

RUN pip3.8 install mkdocs --no-cache-dir --quiet
RUN pip3.8 install mkdocs-material --no-cache-dir --quiet
RUN pip3.8 install pygments --no-cache-dir --quiet
RUN pip3.8 install markdown --no-cache-dir --quiet
RUN pip3.8 install markdown-include --no-cache-dir --quiet
RUN pip3.8 install fontawesome_markdown --no-cache-dir --quiet
RUN pip3.8 install mkdocs-redirects --no-cache-dir --quiet
RUN pip3.8 install mkdocs-material-extensions --no-cache-dir --quiet
RUN pip3.8 install mkdocs-techdocs-core --no-cache-dir --quiet
RUN pip3.8 install mkdocs-git-revision-date-localized-plugin --no-cache-dir --quiet
RUN pip3.8 install mkdocs-awesome-pages-plugin --no-cache-dir --quiet
RUN pip3.8 install mdx_truly_sane_lists --no-cache-dir --quiet
RUN pip3.8 install smarty --no-cache-dir --quiet
RUN pip3.8 install mkdocs-include-markdown-plugin --no-cache-dir --quiet
#RUN pip3.8 install mkdocs_pymdownx_material_extras --no-cache-dir --quiet
RUN pip3.8 install click-man --no-cache-dir --quiet
## click-man --target path/to/man/pages mkdocs
RUN pip3.8 install cookiecutter --no-cache-dir --quiet

## Removing unnecessary dependencies
RUN apt remove -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev g++ python-pip python-dev
RUN rm -rf /var/cache/apt/* /tmp/Python-${PYTHON_VERSION}

## Show versions
RUN echo "NPM version: $(npm --version)"
RUN echo "NODE version: $(node --version)"
RUN echo "PYTHON version: $(python3 --version)"

## Install node dependencies
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
ENTRYPOINT [ "sh", "-c", "mkdocs serve --verbose --dirtyreload" ]
#ENTRYPOINT ["mkdocs"]
#CMD ["serve", "--verbose", "--dirtyreload", "--dev-addr=0.0.0.0:8000"]
