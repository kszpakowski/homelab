
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 19697d758238011c9816c05c5051fe3b560de49b
kustomize build ./hydrator-test
```