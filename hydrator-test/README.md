
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout ad8b80fc3b32ad54fa688e3a2668f7e21aa1dab8
kustomize build ./hydrator-test
```