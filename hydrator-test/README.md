
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout bf4714141bb91a2668ae52e8157b41a211325a3c
kustomize build ./hydrator-test
```