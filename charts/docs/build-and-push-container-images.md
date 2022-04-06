Building docker image with docker command:

```shell
GIT_SHA=$(git rev-parse HEAD)
docker build -f ./distribution/docker-images/dev.Dockerfile -t styled-java-patterns -t styled-java-patterns:$GIT_SHA .
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

Running docker image with `skaffold` command:

```shell
skaffold run --filename='skaffold.docker.yaml' --tail
```

or

Running docker image with `skaffold` command in development mode:

```shell
skaffold dev --filename='skaffold.docker.yaml' --timestamps=true --update-check=true --interactive=true
```

Shutting down docker container with `skaffold` command:

```shell
skaffold delete --filename='skaffold.docker.yaml'
```

Running k8s cluster with `tilt` command by acquiring k8s deployment configuration:

```shell
tilt up
```

Shutting down k8s cluster with `tilt` command with provisioned resources removal:

```shell
tilt down --delete-namespaces
```
