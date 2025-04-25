
# Manifest Hydration

To hydrate the manifests in this repository, run the following commands:

```shell

git clone https://github.com/kszpakowski/homelab.git
# cd into the cloned directory
git checkout 19ccd7bb820f3369dc0ceb9d1629481f8c0dbbb0
kustomize build ./hydrator-test
```