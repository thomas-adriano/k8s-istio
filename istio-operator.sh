#!/bin/bash

ISTIO_VERSION=1.7.3

curl -L "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istioctl-$ISTIO_VERSION-linux-amd64.tar.gz" | tar xz

./istioctl install

kubectl create ns istio-system
kubectl label namespace istio-system istio-injection=enabled
kubectl label namespace default istio-injection=enabled

kubectl apply -f istio-operator.yml

# Addons
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Used by istio-grafana-ingress.yml
export INGRESS_DOMAIN=${INGRESS_HOST}.nip.io
echo "Ingress domain created"

## Grafana HTTP
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/grafana.yaml
kubectl replace --force -f istio-grafana-ingress.yml
while ! kubectl wait --for=condition=available --timeout=600s deployment/grafana -n istio-system; do sleep 1; done
echo "-----> You can access Grafana at http://grafana.${INGRESS_DOMAIN}"

echo "-----> Script finished successfully."
