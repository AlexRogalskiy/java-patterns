# Deploy `java-patterns`

`java-patterns` k8s manifests:

- [common](common)
- [backend](backend)

Deploy `java-patterns` in the `webapp` namespace:

```bash
$ kubectl apply -f ./common
$ kubectl apply -f ./backend
```

Deploy `java-patterns` in the `dev` namespace:

```bash
$ kustomize build ./overlays/dev | kubectl apply -f-
```

Deploy `java-patterns` in the `staging` namespace:

```bash
$ kustomize build ./overlays/staging | kubectl apply -f-
```

Deploy `java-patterns` in the `prod` namespace:

```bash
$ kustomize build ./overlays/prod | kubectl apply -f-
```

## Testing Locally Using Kind

> NOTE: You can install [kind from here](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

The following will create a new cluster called "java-patterns" and configure host ports on 8000 and 8443. You can access the endpoints on localhost. The example also
deploys cert-manager within the cluster along with a self-signed cluster issuer used to generate the certificate to validate the secure port.

```bash
$ ./kind.sh
```
