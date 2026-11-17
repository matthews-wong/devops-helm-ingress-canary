# devops-helm-ingress-canary

A small Helm chart that runs a **stable** and an optional **canary** Deployment
of the same service and splits traffic between them with weighted
ingress-nginx rules.

- Stable and canary each get their own Deployment and Service.
- The canary Ingress carries `nginx.ingress.kubernetes.io/canary` annotations,
  so ingress-nginx sends `canary.weight` percent of requests to the canary.
- Setting `canary.enabled=false` removes every canary resource.

## Usage

```bash
helm install web ./chart -f chart/values-dev.yaml
helm upgrade web ./chart -f chart/values-prod.yaml --set canary.weight=10
```

Promote by moving the canary image tag into `stable.image.tag` and
disabling the canary.

## Validate

See the validation section below once the checks land.
