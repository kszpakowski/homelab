
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 3d9259925c8663b474985fe3aaeee409ea1822aa
kustomize build ./hydrator-test
```