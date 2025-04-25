
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 1b5ab44b050b8ffe0439bc64f5d82f3d2081b11e
kustomize build ./hydrator-test
```