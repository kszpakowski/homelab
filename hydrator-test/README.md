
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 031869fafbb72ac2388c637ae0fb727716e954a6
kustomize build ./hydrator-test
```