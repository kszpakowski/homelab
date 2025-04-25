
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 1fe237e53972895d915010e6eab15bca926f0793
kustomize build ./hydrator-test
```