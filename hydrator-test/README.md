
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 398bc7fa679f412ba4739dbfbf20586314e1a5f6
kustomize build ./hydrator-test
```