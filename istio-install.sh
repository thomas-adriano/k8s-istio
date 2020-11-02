#!/bin/bash

#!/bin/bash
ISTIO_VERSION=1.7.3

curl -L "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istioctl-$ISTIO_VERSION-linux-amd64.tar.gz" | tar xz

./istioctl install --set profile=default -y
kubectl label namespace default istio-injection=enabled --overwrite
kubectl apply -f istio-operator.yml
bash ./check-endpoint.sh istio-system istio-ingressgateway
# Addons
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_DOMAIN=${INGRESS_HOST}.nip.io
echo "Ingress domain created: ${INGRESS_DOMAIN}"

## Grafana HTTP
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/grafana.yaml
bash istio-grafana-ingress.sh
while ! kubectl wait --for=condition=available --timeout=0 deployment/grafana -n istio-system; do sleep 1; done
echo "-----> Grafana available at http://grafana.${INGRESS_DOMAIN}"

## Jaeger HTTP
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/jaeger.yaml
bash istio-jaeger-ingress.sh
while ! kubectl wait --for=condition=available --timeout=0 deployment/jaeger -n istio-system; do sleep 1; done
echo "-----> Tracing (Jaeger) available at http://tracing.${INGRESS_DOMAIN}"

## Prometheus HTTP
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/prometheus.yaml
bash istio-prometheus-ingress.sh
while ! kubectl wait --for=condition=available --timeout=0 deployment/prometheus -n istio-system; do sleep 1; done
echo "-----> Prometheus available at http://prometheus.${INGRESS_DOMAIN}"

## Kiali HTTP
# Currently Kiali only works when executing these 3 almost identic commands.
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml
bash istio-kiali-ingress.sh
while ! kubectl wait --for=condition=available --timeout=0 deployment/kiali -n istio-system; do sleep 1; done
echo "-----> Kiali available at http://kiali.${INGRESS_DOMAIN}"

## END
echo "-----> Script finished successfully."