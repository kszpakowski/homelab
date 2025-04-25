
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 457c186b3f4e2e473905dd4351b7c52d73997ad6
kustomize build ./hydrator-test
```