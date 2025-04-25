
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout a26462659c2dbbb0c0e4c61a675277788442fa19
kustomize build ./hydrator-test
```