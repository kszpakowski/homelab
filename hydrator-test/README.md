
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 0e56c85fd59a567842962bda44f320895b11a432
kustomize build ./hydrator-test
```