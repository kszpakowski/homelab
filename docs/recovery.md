# Homelab deployment and recovery

This public runbook describes procedures only. Keep credentials, user identifiers,
cluster access details, backup locations, and incident logs in private storage.

## Deploy a configuration change

1. Update the application's manifests in `applications/<application>`.
2. Render them with `kustomize build applications/<application>/overlays/homelab`.
3. Review the rendered changes, commit, and push. Argo CD's homelab ApplicationSet
   discovers application directories and automatically reconciles the main branch.
4. Check the application's sync and health in Argo CD, then verify the service.

Backstage's additional catalog entries live in
`applications/backstage/base/catalog/services.yaml`. Kustomize packages these
into a ConfigMap whose content hash triggers a deployment when entries change.
The image's existing catalog continues to supply identities, ownership, and the
Backstage component. Do not copy its identity data into this public repository.

## Diagnose an unavailable service

Use a trusted machine with your private cluster access configured:

```sh
kubectl -n <namespace> get pods,deployments,statefulsets,services,ingresses,pvc
kubectl -n <namespace> get events --sort-by=.metadata.creationTimestamp
kubectl -n <namespace> describe pod <pod>
kubectl -n <namespace> logs <pod> --all-containers --tail=100
```

Check Argo CD sync, image availability, storage attachment, database readiness,
DNS, and TLS. Keep diagnostic output private; logs may contain sensitive data.

For Backstage, check the deployment rollout and its readiness endpoint:

```sh
kubectl -n backstage rollout status deployment/backstage
kubectl -n backstage get cluster,pods,oidcclient
```

If catalog pages look empty, select **All** rather than **Owned** in the catalog,
clear filters, and inspect catalog processing errors. Check that the mounted
catalog ConfigMap is present and both file locations are loaded. A service entry
is inventory metadata; it does not create or deploy the service.

## Roll back a bad configuration

Revert the specific offending Git commit, review and push the revert, then wait
for Argo CD to reconcile. Verify service readiness and sign-in afterwards.
Prefer a Git revert over a manual live edit, which automatic reconciliation can
overwrite. Database migrations and data changes require their own recovery plan;
a manifest rollback does not reverse them.

## Backups and data recovery

Backstage currently has a single PostgreSQL instance and no dedicated backup
policy in this repository. Persistent volumes and Git are not database backups.
Do not assume a usable database recovery point exists until a restore is tested.

Maintain independent backups of PostgreSQL and application-owned files. Immich
requires both its photo library and database; n8n recovery also requires its
original encryption key. Store keys and backup destinations privately.

Before restoring data:

1. Identify and verify a backup using the private backup inventory.
2. Stop writes and preserve the current data for investigation.
3. Restore into a separate database or isolated environment using the procedure
   appropriate to the backup tool. Verify versions, required extensions, and keys.
4. Check record counts, sign-in, and representative application data.
5. Switch the application to the verified restore and check readiness before
   resuming writes. Record the recovery point and any lost changes privately.

Do not delete a PVC as a troubleshooting step: a storage class with a Delete
reclaim policy can permanently delete its data.

## Documentation in Backstage

Each new catalog entry links to this runbook in GitHub. The TechDocs tab requires
a separate documentation build and publishing pipeline; these links work without
that pipeline. Keep private recovery details out of published documentation.
