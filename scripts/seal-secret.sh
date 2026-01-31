#!/bin/bash

read -p "Secret name: " SECRET_NAME
read -p "Secret namespace: " SECRET_NS

FROM_LITERALS=()

echo "Enter secret keys and values."
echo "Leave key empty and press Enter when done."
echo

while true; do
  read -p "Secret key: " SECRET_KEY
  [ -z "$SECRET_KEY" ] && break

  read -s -p "Secret value: " SECRET_VALUE
  echo

  FROM_LITERALS+=(--from-literal="$SECRET_KEY=$SECRET_VALUE")
done

if [ ${#FROM_LITERALS[@]} -eq 0 ]; then
  echo "No keys provided. Exiting."
  exit 1
fi

kubectl create secret generic "$SECRET_NAME" \
  "${FROM_LITERALS[@]}" \
  --dry-run=client -o yaml | \
  kubeseal -o yaml --scope namespace-wide -n "$SECRET_NS" | \
  yq 'del(.metadata.creationTimestamp, .spec.template.metadata.creationTimestamp)' > \
  "$SECRET_NAME-sealedsecret.yaml"

echo "Sealed secret $SECRET_NAME-sealedsecret.yaml created."