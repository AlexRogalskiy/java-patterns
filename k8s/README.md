# Deploy demo webapp

Demo webapp manifests:

- [common](common)
- [backend](backend)

Deploy the demo in `webapp` namespace:

```bash
kubectl apply -f ./common
kubectl apply -f ./backend
```

Deploy the demo in the `dev` namespace:

```bash
kustomize build ./overlays/dev | kubectl apply -f-
```

Deploy the demo in the `staging` namespace:

```bash
kustomize build ./overlays/staging | kubectl apply -f-
```

Deploy the demo in the `prod` namespace:

```bash
kustomize build ./overlays/prod | kubectl apply -f-
```

## Testing Locally Using Kind

> NOTE: You can install [kind from here](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

The following will create a new cluster called "podinfo" and configure host ports on 80 and 443. You can access the endpoints on localhost. The example also
deploys cert-manager within the cluster along with a self-signed cluster issuer used to generate the certificate to validate the secure port.

```sh
./kind.sh
```
