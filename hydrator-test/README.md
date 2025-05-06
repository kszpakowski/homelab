
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout fae264815feabe4029eccfde0f57caa1ed4bc4f2
kustomize build ./hydrator-test
```