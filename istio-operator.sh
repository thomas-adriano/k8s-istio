#!/bin/bash

ISTIO_VERSION=1.7.3

curl -L "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istioctl-$ISTIO_VERSION-linux-amd64.tar.gz" | tar xz

./istioctl install -y

kubectl create ns istio-system
kubectl label namespace istio-system istio-injection=enabled
kubectl label namespace default istio-injection=enabled

kubectl apply -f istio-operator.yml
while ! kubectl wait --for=condition=available --timeout=600s service/istio-ingressgateway -n istio-system; do sleep 1; done
# Addons
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_DOMAIN=${INGRESS_HOST}.nip.io
echo "Ingress domain created: ${INGRESS_DOMAIN}"

## Grafana HTTP
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/grafana.yaml
bash istio-grafana-ingress.sh
while ! kubectl wait --for=condition=available --timeout=600s deployment/grafana -n istio-system; do sleep 1; done
echo "-----> You can access Grafana at http://grafana.${INGRESS_DOMAIN}"

## Jaeger HTTP
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/jaeger.yaml
bash istio-jaeger-ingress.sh
while ! kubectl wait --for=condition=available --timeout=600s deployment/istio-tracing -n istio-system; do sleep 1; done
echo "-----> You can access tracing (Jaeger) at http://tracing.${INGRESS_DOMAIN}"

## END
echo "-----> Script finished successfully."