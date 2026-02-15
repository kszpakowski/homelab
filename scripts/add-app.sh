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

confirm() {
  local prompt="$1"
  local ans
  read -r -p "$prompt [y/N]: " ans
  case "${ans:-}" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
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
mkdir -p ${APP_DIR}

if ! confirm "Initialize kustomize?"; then
    exit 0
fi


BASE_DIR="${APP_DIR}/base"
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


OVERLAY_DIR="${APP_DIR}/overlays/homelab"
mkdir -p ${OVERLAY_DIR}
cat > "$OVERLAY_DIR/kustomization.yaml" <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
EOF