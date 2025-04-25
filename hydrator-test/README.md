
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout aac4e73cf06e3ac77d4d31a23ca784ff960f7264
kustomize build ./hydrator-test
```