# k8s-istio

Istio deployment scripts and configurations

# Cheatcheet

## Remove hanging k8s resource (namespace, service, pod, etc)

- run: kubectl get $RESOURCE $RESOURCE_NAME -o json > resource.json
  - ex.: kubectl get namespace my-namespace -o json > resource.json
- remove "Kubernetes" from the spec.finalizerrs array;
- run: kubectl replace --raw "/api/v1/$RESOURCE/$RESOURCE_NAME/finalize" -f ./resource.json
  - ex.: kubectl replace --raw "/api/v1/namespace/my-namespace/finalize" -f ./resource.json
