
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 4ca7602a22a9a54145cec5ec0a244a8c6d98c8a6
kustomize build ./hydrator-test
```