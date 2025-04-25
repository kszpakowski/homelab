
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 26ab37589f7fedc9a0f8adbfc15850a31d8a337b
kustomize build ./hydrator-test
```