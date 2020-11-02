#!/bin/bash
# Pass the name of a service to check ie: sh check-endpoint.sh staging-voting-app-vote
# Will run forever...
external_ip=""
while [ -z $external_ip ]; do
  echo "Waiting for endpoint: namespace $1, service $2"
  external_ip=$(kubectl -n $1 get svc $2 --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$external_ip" ] && sleep 10
done
echo 'End point ready:' && echo $external_ip