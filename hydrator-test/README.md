
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout fcf83fe7afe797b875b9687d30390d8fc90a81f2
kustomize build ./hydrator-test
```