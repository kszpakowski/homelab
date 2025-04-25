
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout abb1c7ca488bc29278ba8c2065b6eefbdd5b3f76
kustomize build ./hydrator-test
```