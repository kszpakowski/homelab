#!/bin/bash
read -p "Secret name: " SECRET_NAME
read -p "Secret namespace: " SECRET_NS
read -p "Secret key: " SECRET_KEY
read -p "Secret value: " SECRET_VALUE
kubectl create secret generic $SECRET_NAME --from-literal=$SECRET_KEY="$SECRET_VALUE" --dry-run=client -o yaml | \
  kubeseal -o yaml --scope namespace-wide -n $SECRET_NS | \
  yq 'del(.metadata.creationTimestamp, .spec.template.metadata.creationTimestamp)' > \
  $SECRET_NAME-sealedsecret.yaml

echo "Sealed secret $SECRET_NAME-sealedsecret.yaml created."