
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 6b9b31556788c0b81fd947312b8dba1a6b54db2e
kustomize build ./hydrator-test
```