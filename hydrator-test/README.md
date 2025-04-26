
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 2938d741b9b6d9cd3bd80512626a92eec5bba8bd
kustomize build ./hydrator-test
```