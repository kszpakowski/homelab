#!/usr/bin/env python3
"""Add or refresh a repository runner without saving a GitHub PAT to the cluster."""
import argparse
import json
from pathlib import Path
import re
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('repository', help='OWNER/REPO, for example kszpakowski/backstage')
args = parser.parse_args()
if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', args.repository):
    parser.error('repository must be OWNER/REPO')
name = args.repository.split('/')[1].lower().replace('_', '-').replace('.', '-')
if len(name) > 40 or not re.fullmatch(r'[a-z0-9][a-z0-9-]*[a-z0-9]|[a-z0-9]', name):
    parser.error('repository name must produce a valid Kubernetes name of at most 40 characters')
root = Path(__file__).resolve().parent.parent
base = root / 'applications/github-actions-runners/base'
instance = base / name
config_path = instance / 'kustomization.yaml'
if config_path.exists() and f'GITHUB_REPOSITORY={args.repository}' not in config_path.read_text():
    parser.error('a runner with this name already belongs to another repository')
# Capture responses; registration tokens must never be printed or stored in plaintext.
response = subprocess.run(
    ['gh', 'api', '--method', 'POST', f'repos/{args.repository}/actions/runners/registration-token'],
    check=True, capture_output=True, text=True,
)
secret = {
    'apiVersion': 'v1', 'kind': 'Secret',
    'metadata': {'name': f'{name}-runner-registration', 'namespace': 'github-actions-runners'},
    'stringData': {'token': json.loads(response.stdout)['token']},
}
sealed = subprocess.run(
    ['kubeseal', '--controller-name=sealed-secrets-controller',
     '--controller-namespace=kube-system', '--format=yaml'],
    input=json.dumps(secret), capture_output=True, text=True, check=True,
)
instance.mkdir(parents=True, exist_ok=True)
config_path.write_text(f'''apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: {name}-
components:
  - ../../components/runner
labels:
  - pairs:
      app.kubernetes.io/instance: {name}
    includeSelectors: true
patches:
  - target:
      kind: Deployment
      name: runner
    patch: |-
      - op: replace
        path: /spec/template/spec/volumes/1/secret/secretName
        value: {name}-runner-registration
configMapGenerator:
  - name: runner-config
    literals:
      - GITHUB_REPOSITORY={args.repository}
      - RUNNER_NAME=homelab-{name}
''')
sealed_path = base / f'{name}-registration-sealedsecret.yaml'
sealed_path.write_text(sealed.stdout)
base_config = base / 'kustomization.yaml'
content = base_config.read_text()
for resource in [name, sealed_path.name]:
    if f'  - {resource}\n' not in content:
        content += f'  - {resource}\n'
base_config.write_text(content)
print(f'Prepared runner homelab-{name} for {args.repository}.')
print('Validate, commit and push applications/github-actions-runners within one hour for initial registration.')
print('Existing registration is retained on the runner PVC across restarts.')
