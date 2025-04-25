
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 112f0835b97490b14534cecd44edd2d106e354e1
kustomize build ./hydrator-test
```