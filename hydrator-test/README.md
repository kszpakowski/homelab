
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout d094db8021ea4a305a0fad949c75624ffa27c663
kustomize build ./hydrator-test
```