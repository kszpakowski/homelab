# Backstage

Portal: https://backstage.homelab.kszpakowski.com
Source and image CI: https://github.com/kszpakowski/backstage
Registry: `zot.homelab.kszpakowski.com/backstage`

Argo CD discovers this directory through the homelab ApplicationSet.
CloudNativePG provides a single 10Gi PostgreSQL instance using
`proxmox-data-ext4`. Backstage plugins use schemas within the `backstage`
database, so the app role does not require cluster-wide database privileges.
Pocket ID operator creates `backstage-oidc`; Sealed Secrets creates
`backstage-session`. No plaintext credentials are committed.

Image CI publishes `main`, immutable `sha-<full commit SHA>` tags, and version
tags. Update `base/deployment.yaml` to an immutable image after a successful build,
then commit and push to this repository. Argo CD rolls out the new image.

Sign-in is restricted to explicitly onboarded catalog users, matched by Pocket
ID subject. The initial user is Karol. Add users in the Backstage source catalog.
GitHub integrations initially support public repositories only. TechDocs requires
an external documentation publishing pipeline before documentation is available.

## Verification

```sh
kustomize build applications/backstage/overlays/homelab
kubectl -n backstage get cluster,pods,oidcclient
kubectl -n backstage rollout status deployment/backstage
curl -f https://backstage.homelab.kszpakowski.com/.backstage/health/v1/readiness
```

The database has one instance and no dedicated backup policy yet; include it in
your homelab backup strategy before relying on irreplaceable catalog data.
