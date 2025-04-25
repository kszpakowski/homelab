
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 1cb88018ea6bd2b217a2d90716874c3a4f8027c8
kustomize build ./hydrator-test
```