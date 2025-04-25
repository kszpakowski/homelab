
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 33382883650ecb538a82334fba485415916192f5
kustomize build ./hydrator-test
```