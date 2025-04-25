
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout a0f310fcfd5e4313335dca86ed9d4fab12a6ca2b
kustomize build ./hydrator-test
```