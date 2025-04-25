
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 5dbe0a67cd50abd59240756afca9cb6a0ee04556
kustomize build ./hydrator-test
```