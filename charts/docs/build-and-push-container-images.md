Building docker image with docker command:

```shell
GIT_SHA=$(git rev-parse HEAD)
docker build -f Dockerfile -t styled-java-patterns -t styled-java-patterns:$GIT_SHA --build-arg VERCEL_TOKEN=$1 .
```

Running docker image via `docker-compose` command:

```shell
docker-compose -f docker-compose.yml build
docker-compose -f docker-compose.yml up -d
```

Removing docker image via `docker-compose` command:

```shell
docker-compose -f docker-compose.yml down -v --remove-orphans
```

Running k8s cluster with `tilt` command by acquiring k8s deployment configuration:

```shell
tilt up
```

Shutting down k8s cluster with `tilt` command with provisioned resources removal:

```shell
tilt down --delete-namespaces
```
