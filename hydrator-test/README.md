
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 92aaca9b94d4750cc0e692e00b3e926fabe630de
kustomize build ./hydrator-test
```