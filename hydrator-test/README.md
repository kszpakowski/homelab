
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 8df1016b19a1a1976e996236bee734b1747d4b52
kustomize build ./hydrator-test
```