# Hello Kubernetes!

This container image can be deployed on a Kubernetes cluster. It runs a web app, that displays the following:

- a default **Hello world!** message
- namespace, pod, and node details
- container image details

## Quick start

You can deploy `java-patterns` to your Kubernetes cluster using [Helm 3](https://helm.sh/docs/intro/install/). The Helm chart installation and configuration
options can be found in the [Deploy using Helm](docs/deploy-using-helm.md) guide.

When running through the following examples, ensure that you are in the chart directory in the repo, since you are referencing a local helm chart.

```bash
$ cd helm
```

### Example 1: Default

Deploy the `java-patterns` app into the `webapp` namespace. The app is exposed via a public Load Balancer on port 80 by default - note that a LoadBalancer
service typically only works in cloud provider based Kubernetes offerings.

```bash
$ helm upgrade --install backend-java-patterns -f values.yaml --create-namespace --namespace webapp .

# get the LoadBalancer ip address.
$ kubectl get svc webapp-backend-java-patterns -n webapp -o 'jsonpath={ .status.loadBalancer.ingress[0].ip }'
```

### Example 2: Custom message

Deploy the `java-patterns` app into the `webapp` namespace with an "I just deployed this on Kubernetes!" message. The app is exposed via a public Load Balancer
on port 80 by default - note that a LoadBalancer service typically only works in cloud provider based Kubernetes offerings.

```bash
$ helm upgrade --install backend-java-patterns -f values.yaml --create-namespace --namespace webapp . --set message="I just deployed this on Kubernetes!"

# get the LoadBalancer ip address.
$ kubectl get svc webapp-backend-java-patterns -n webapp -o 'jsonpath={ .status.loadBalancer.ingress[0].ip }'
```

### Example 3: Ingress

Deploy the `java-patterns` app into the `webapp` namespace. This example assumes that an ingress has been deployed and configured in the cluster, and that the
ingress has a path of `/app/java-patterns/` mapped to the `java-patterns` service.

The `java-patterns` app can be reached on the ip address of the ingress via the `/app/java-patterns/` path.

```bash
$ helm upgrade --install backend-java-patterns -f values.yaml --create-namespace --namespace webapp ingress . \
  --set ingress.configured=true \
  --set ingress.pathPrefix="/app/java-patterns/" \
  --set service.type="ClusterIP"
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```bash
$ helm install --create-namespace --namespace webapp backend-java-patterns . -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### Example 4: Helm uninstall

```bash
helm uninstall backend-java-patterns --namespace webapp
```

### Example 5: Helm status

```bash
helm status backend-java-patterns --namespace webapp
```

### Example 6: Helm list

```bash
helm list --namespace webapp
```

### Example 7: Helm lint

```bash
helm lint charts
```

## Documentation

### Deploying

If you'd like to explore the various Helm chart configuration options, then read the [Deploy with Helm](charts2/docs/deploy-using-helm.md) documentation. You can also
discover more about the ingress configuration options in the [Deploy with ingress](charts2/docs/deploy-with-ingress.md) documentation

### Building your own images

If you'd like to build the `java-patterns` container image yourself and reference from your own registry or DockerHub repository, then you can get more details
on how to do this in the [Build and push container images](charts2/docs/build-and-push-container-images.md) documentation.

### Development environment

If you have [VS Code](https://code.visualstudio.com/) and
the [VS Code Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension installed, the `.devcontainer`
folder will be used to provide a container based development environment. You can read more about how to use this in
the [Development environments](docs/development-environment.md) documentation.

## Upgrading the chart

### To =< 5.0.0

Version 5.0.0 is a major update.

- The chart now follows the new Kubernetes label recommendations:
  <https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/>

The simplest way to update is to do a force upgrade, which recreates the resources by doing a delete and an install.
