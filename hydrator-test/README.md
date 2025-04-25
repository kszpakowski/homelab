
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 0d83334abd2af24d3dcea9aa62f7c3eef834eb7c
kustomize build ./hydrator-test
```