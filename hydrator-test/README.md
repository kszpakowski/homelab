
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout e150aae78ea9baf12d8b86ea3e216b1f97496e1e
kustomize build ./hydrator-test
```