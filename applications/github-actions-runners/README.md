# Homelab GitHub Actions runners

Reusable repository-scoped runners for the personal `kszpakowski` account.
The first registration is for `kszpakowski/backstage`. Each repository receives
its own runner pod, rootless BuildKit builder, and 40Gi PVC. GitHub permits organization
runners to serve multiple repositories; personal accounts use separate
repository registrations.

The common component lives in `components/runner`. Instance kustomizations add a
unique name prefix, selector and repository configuration. The runner uses the
official GitHub image, keeps registration and workspace data on its PVC, and
updates its runner binary automatically. Image builds use BuildKit running as
UID 1000, with the native snapshotter and no Docker daemon. The builder API
listens on pod loopback only; no Service, host mounts or Docker socket are used.

BuildKit needs an unconfined seccomp profile to create user namespaces and uses
`--oci-worker-no-process-sandbox`: build steps share the builder's process
sandbox. This is suitable for trusted repository code. The runner itself runs as
UID 1001; a setup init container initializes its PVC as container root, and sudo
installs compilation dependencies inside the runner container at startup.
No container uses `privileged: true` or added Linux capabilities.

Talos's baseline Pod Security policy rejects the builder seccomp exception.
The namespace therefore has a Pod Security admission exemption, paired with a
fail-closed ValidatingAdmissionPolicy that forbids privileged containers, host
network/PID/IPC namespaces, host path mounts and added Linux capabilities.
The policy and binding apply before the namespace exemption in Argo CD sync
waves. Keep the guard policy active; it replaces those baseline checks for this
namespace. Pods have no Kubernetes service-account token and inbound networking
is denied. Rootless builds still have access to the pod network and should run
only trusted code.

## Add a repository

```sh
./scripts/add-github-runner.py kszpakowski/REPOSITORY
kustomize build applications/github-actions-runners/overlays/homelab
```

The helper obtains a one-hour registration token through your authenticated
`gh` CLI and seals it using the cluster key. It never stores your CLI access token
in Kubernetes. Commit and push the generated configuration within one hour;
Argo CD deploys it. Refresh registration with the same command if initial setup
expires. Subsequent restarts reuse the registration on the PVC.

Select this runner in a repository workflow:

```yaml
runs-on: [self-hosted, Linux, X64, homelab, zot]
```

Use `"$BUILDKIT_CLIENT" build` to build Dockerfiles; `BUILDKIT_HOST` points to
the rootless sidecar. Docker-based actions and Docker service containers require
a Docker daemon and are not supported by this runner. See the Backstage workflow
for image publishing and registry cache configuration.

Every repository processes one job at a time. Adding repositories adds pods, so
check cluster CPU, memory and storage capacity. For public repositories, prevent
fork pull requests from reaching these runners: use GitHub-hosted runners for
untrusted pull requests and run homelab image publishing only on trusted pushes.

## Recovery and removal

Keep the PVC to preserve registration across pod restarts. If it is lost, remove
the offline runner in repository Settings / Actions / Runners and refresh the
registration token. To remove a repository, delete its entries from
`base/kustomization.yaml`, then remove its directory and sealed secret and remove
the GitHub runner registration. Argo CD pruning deletes its PVC and workspace.
