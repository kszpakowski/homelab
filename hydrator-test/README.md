
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 2bd77b9bc0ba0ed4c57fe61b30a1462d56ceb986
kustomize build ./hydrator-test
```