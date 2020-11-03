#!/bin/bash

echo "Using minikube? (Y/N default N)"
read IS_MINIKUBE

# ISTIO_VERSION=1.7.3

# if ! command -v ./istioctl &> /dev/null
# then
#     curl -L "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istioctl-$ISTIO_VERSION-linux-amd64.tar.gz" | tar xz
# fi

# ./istioctl install --set profile=default -y
# kubectl label namespace default istio-injection=enabled --overwrite
# kubectl apply -f istio-operator.yml

# Addons
case $IS_MINIKUBE in
    y|Y)
        export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
        export MINIKUBE_IP=$(minikube ip)
        export INGRESS_DOMAIN=${MINIKUBE_IP}.nip.io
    ;;
    *)
        bash ./check-endpoint.sh istio-system istio-ingressgateway
        export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        export INGRESS_DOMAIN=${INGRESS_HOST}.nip.io
    ;;
esac

echo "Ingress domain created: ${INGRESS_DOMAIN}"

# ## Grafana HTTP
# kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/grafana.yaml
# bash istio-grafana-ingress.sh
# while ! kubectl wait --for=condition=available --timeout=0 deployment/grafana -n istio-system; do sleep 1; done
# echo "-----> Grafana available at http://grafana.${INGRESS_DOMAIN}"

## Jaeger HTTP
kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/jaeger.yaml
bash istio-jaeger-ingress.sh
while ! kubectl wait --for=condition=available --timeout=0 deployment/jaeger -n istio-system; do sleep 1; done
echo "-----> Tracing (Jaeger) available at http://tracing.${INGRESS_DOMAIN}"

# ## Prometheus HTTP
# kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/prometheus.yaml
# bash istio-prometheus-ingress.sh
# while ! kubectl wait --for=condition=available --timeout=0 deployment/prometheus -n istio-system; do sleep 1; done
# echo "-----> Prometheus available at http://prometheus.${INGRESS_DOMAIN}"

# ## Kiali HTTP
# # Currently Kiali only works when executing these 3 almost identic commands.
# kubectl replace --force -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/addons/kiali.yaml
# bash istio-kiali-ingress.sh
# while ! kubectl wait --for=condition=available --timeout=0 deployment/kiali -n istio-system; do sleep 1; done
# echo "-----> Kiali available at http://kiali.${INGRESS_DOMAIN}"

# case $IS_MINIKUBE in
#     y|Y)
#         minikube tunnel &
#         echo "Minikube tunnel started"
#     ;;
#     *)

#     ;;
# esac

# ## END
# echo "-----> Script finished successfully."