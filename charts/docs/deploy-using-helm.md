# Deploy using Helm

The `java-patterns` Helm chart can be used to deploy the `java-patterns` application. The chart will deploy the following resources:

- ServiceAccount
- Service
- Deployment

## Prerequisites

- [Helm 3](https://v3.helm.sh/)

If you are using the [VS Code Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) based development
environment, all of the prerequisites will be available in the terminal.

## Configuration and installation

The following table lists the configuration parameters of the java-patterns chart, and their default values.

| Parameter | Type | Default | Description |
| --------- | ---- | ------- | ----------- |
| `message` | `string` | `""` | A custom message to display instead of the default. |
| `ingress.configured` | `bool` | `false` | Indicates whether an ingress has been configured in the cluster. <br/>Note: this chart will not install or configure an ingress. You will need to install an ingress controller and add ingress record to the app namespace. |
| `ingress.rewritePath` | `bool` | `true` | Indicates whether pathPrefix is rewritten by the ingress. <br/> If this is set to `true` then the java-patterns dynamic content and static assets will be served from `/`, otherwise, they will be served from `/$pathPrefix`. |
| `ingress.pathPrefix` | `string` | `""` | The path prefix configured in the ingress for the java-patterns service.<br/> Must be provided when ingress is used. |
| `service.type` | `string` | `"LoadBalancer"` | The service type. |
| `service.port` | `int` | `80` | The port exposed by the service. |
| `deployment.replicas` | `int` | `2` | The number of replicas for the java-patterns deployment. |
| `deployment.container.image.repository` | `string` | `java-patterns` | The container image to run in the java-patterns pods. |
| `deployment.container.image.tag` | `string` | `""` | The container image tag. If not specified, the chart's appVersion is used. |
| `deployment.container.image.pullPolicy` | `string` | `"IfNotPresent"` | The pull policy for the container image. |
| `deployment.container.port` | `int` | `"8080"` | The port that java-patterns app listens on. |
| `deployment.nodeSelector` | `object` | `{"kubernetes.io/os":"linux", "kubernetes.io/arch":"amd64"}` | The node selector for the deployment. |
| `deployment.resources` | `object` | `{}` | The resource limits for the deployment. |
| `deployment.tolerations` | `object` | `[]` | The tolerations for the deployment. |
| `deployment.affinity` | `object` | `{}` | The affinity for the deployment. |

### Installing the chart

Ensure that you are in the chart directory in the repo, since the instructions reference a local helm chart.

To install `java-patterns` via the Helm chart, use the following to:

- create the webapp namespace if it doesn't exist
- deploy the chart located in the current folder into the webapp namespace
- create a Helm release named java-patterns

```bash
$ helm install --create-namespace --namespace webapp java-patterns .
```

You can override the values for the configuration parameter defined in the table above, either directly in the `values.yaml` file, or via the `--set` switches.

```bash
$ helm install --create-namespace --namespace webapp custom-message . --set message="I just deployed this on Kubernetes!"
```

### Upgrading the chart

Ensure that you are in the chart directory in the repo, since the instructions reference a local helm chart.

You can modify the `java-patterns` app by providing new values for the configuration parameter defined in the table above, either directly in the `values.yaml`
file, or via the `--set` switches.

```bash
$ helm upgrade --namespace webapp custom-java-patterns . --set message="This is a different message"
```

### Uninstalling the chart

You can uninstall the `java-patterns` app as follows:

```bash
$ helm uninstall --namespace webapp custom-java-patterns
```
