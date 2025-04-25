
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 1cfacb8e92ace579c2d25af9a66a8f8645c23f8a
kustomize build ./hydrator-test
```