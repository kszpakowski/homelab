# Homelab deployment and recovery

This public runbook describes procedures only. Keep credentials, user identifiers,
cluster access details, backup locations, and incident logs in private storage.

## Deploy a configuration change

1. Update the application's manifests in `applications/<application>`.
2. Render them with `kustomize build applications/<application>/overlays/homelab`.
3. Review the rendered changes, commit, and push. Argo CD's homelab ApplicationSet
   discovers application directories and automatically reconciles the main branch.
4. Check the application's sync and health in Argo CD, then verify the service.

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

## Roll back a bad configuration

Revert the specific offending Git commit, review and push the revert, then wait
for Argo CD to reconcile. Verify service readiness and sign-in afterwards.
Prefer a Git revert over a manual live edit, which automatic reconciliation can
overwrite. Database migrations and data changes require their own recovery plan;
a manifest rollback does not reverse them.

## Backups and data recovery

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
