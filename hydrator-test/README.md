
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 1139977774941e283f6da068298fdb6bcab69726
kustomize build ./hydrator-test
```