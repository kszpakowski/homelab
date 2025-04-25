
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout e9896729816eefe662aecafe8d0c409f670f4137
kustomize build ./hydrator-test
```