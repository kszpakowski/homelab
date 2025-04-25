
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 84a5ae1157390ac14482677438fd0efc5e1963c5
kustomize build ./hydrator-test
```