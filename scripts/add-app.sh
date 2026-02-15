#!/usr/bin/env bash
set -euo pipefail

prompt_default() {
  local prompt="$1"
  local default="$2"
  local out
  read -r -p "$prompt [$default]: " out
  if [[ -z "${out:-}" ]]; then
    echo "$default"
  else
    echo "$out"
  fi
}

sanitize_name() {
  # Kubernetes-ish name: lowercase, alnum + '-', no leading/trailing '-'
  local s="$1"
  s="$(echo "$s" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9-]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"
  [[ -n "$s" ]] || die "App name became empty after sanitizing."
  echo "$s"
}

RAW_APP_NAME="$(prompt_default "App name" "my-app")"
APP_NAME="$(sanitize_name "$RAW_APP_NAME")"

APP_DIR="./applications/${APP_NAME}"
BASE_DIR="${APP_DIR}/base"
OVERLAY_DIR="${APP_DIR}/overlays/kustomize"

mkdir -p ${BASE_DIR}
cat > "$BASE_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
helmCharts: []
#   - name: ${APP_NAME}
#     repo: oci://zot.homelab.kszpakowski.com/${APP_NAME}
#     version: 1.0.0
#     releaseName: ${APP_NAME}
#     namespace: ${APP_NAME}
#     valuesInline: {}
resources: []
# - ${APP_NAME}.yaml

EOF



mkdir -p ${OVERLAY_DIR}

cat > "$OVERLAY_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base

EOF