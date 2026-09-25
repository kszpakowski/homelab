# Directus travel planner CMS

This application deploys Directus with a single-instance CloudNativePG cluster and persistent local media storage. Argo CD discovers the `applications/directus` directory through the repository's existing ApplicationSet.

## Components

- Directus `12.4.1`, exposed at `https://travel-cms.homelab.kszpakowski.com`
- CloudNativePG PostgreSQL with a 10 GiB `proxmox-data-ext4` volume
- a 20 GiB `proxmox-data-ext4` volume mounted at `/directus/uploads`
- Traefik ingress, a `letsencrypt` certificate, and an external-dns hostname annotation

The database credentials are generated and rotated by CloudNativePG in the `directus-postgres-app` Secret. Non-sensitive application settings live in `base/configmap.yaml`. Directus' signing secret and the initial administrator credentials must be supplied separately as SealedSecrets.

## One-time setup

Do this before allowing Argo CD to sync the application for the first time.

1. Confirm that `travel-cms.homelab.kszpakowski.com` is the intended hostname. If not, change it in both `overlays/homelab/ingress.yaml` and `overlays/homelab/configmap-patch.yaml`.
2. Generate a stable Directus signing secret. Do not commit its plaintext value:

   ```sh
   kubectl -n directus create secret generic directus-runtime-secrets \
     --from-literal=SECRET="$(openssl rand -hex 32)" \
     --dry-run=client -o yaml \
     | kubeseal --format yaml \
     > applications/directus/overlays/homelab/runtime-secrets-sealedsecret.yaml
   ```

3. Create the initial administrator secret, again without committing plaintext credentials:

   ```sh
   kubectl -n directus create secret generic directus-bootstrap-admin \
     --from-literal=ADMIN_EMAIL='replace-with-admin-email' \
     --from-literal=ADMIN_PASSWORD='replace-with-a-long-random-password' \
     --dry-run=client -o yaml \
     | kubeseal --format yaml \
     > applications/directus/overlays/homelab/bootstrap-admin-sealedsecret.yaml
   ```

4. Add both generated SealedSecret filenames to `resources` in `overlays/homelab/kustomization.yaml`, commit them, and let Argo CD sync. The sealed ciphertext is safe to store in Git and can only be decrypted by the cluster's sealed-secrets controller.
5. Verify the administrator can sign in. The bootstrap variables only affect an empty database. After first login, rotate the administrator password. The bootstrap SealedSecret may then be removed from the overlay and cluster; the Deployment treats it as optional. Keep `directus-runtime-secrets` for the lifetime of the installation, otherwise active sessions and signed tokens will break.

The external-dns annotation should create DNS automatically. If the configured provider does not manage this zone, create the matching DNS record manually. cert-manager will issue `directus-cert` after DNS and ingress routing work.

## Travel planner model

`schema/travel-planner.sql` defines a content-only relational model:

- `trips` has many `days`;
- `days` has ordered `stops`;
- each `stop` points to one reusable `place`;
- a `place` can reference one Directus-managed cover image.

It contains no users, roles, permissions, secrets, or content. Apply it once, after Directus has completed its initial bootstrap (the `directus_files` table must already exist):

```sh
kubectl -n directus exec -i directus-postgres-1 -- \
  psql --username directus --dbname directus \
  < applications/directus/schema/travel-planner.sql
```

Directus introspects the tables and foreign keys. In Data Studio, review the four collections, set display templates (`trips.title`, `days.title`, `places.name`), configure the reverse one-to-many aliases, and create least-privilege access policies. Do not grant public access unless the eventual frontend explicitly needs it.

Once the UI metadata is finalized, capture it as the versioned source of truth from the running Directus pod:

```sh
kubectl -n directus exec deploy/directus -- \
  node cli.js schema snapshot --yes /tmp/travel-planner.yaml
kubectl -n directus cp \
  "$(kubectl -n directus get pod -l app=directus -o jsonpath='{.items[0].metadata.name}'):/tmp/travel-planner.yaml" \
  applications/directus/schema/travel-planner.yaml
```

Before applying a later snapshot, inspect its impact and take a PostgreSQL backup:

```sh
kubectl -n directus cp applications/directus/schema/travel-planner.yaml \
  deploy/directus:/tmp/travel-planner.yaml
kubectl -n directus exec deploy/directus -- \
  node cli.js schema apply --dry-run /tmp/travel-planner.yaml
kubectl -n directus exec deploy/directus -- \
  node cli.js schema apply --yes /tmp/travel-planner.yaml
```

Schema snapshots do not contain content, users, roles, or permissions.

## Operations and trade-offs

- Directus runs one replica because the repository's local storage class provides `ReadWriteOnce` volumes. The `Recreate` strategy prevents two pods from mounting the uploads volume during upgrades.
- PostgreSQL also runs one instance, matching the existing homelab CloudNativePG pattern. PVCs survive pod replacement, but this is not high availability and is not a backup.
- No object-store or backup destination is configured in this repository. Before production use, configure scheduled CloudNativePG backups and off-cluster copies of the uploads PVC.
- The container image is pinned to a release tag rather than `latest`. Review Directus release notes and database backups before changing it.
- Directus exposes its standard `/server/health` endpoint through startup, readiness, and liveness probes. The existing cluster monitoring stack can observe pod and Kubernetes health; Directus does not expose Prometheus application metrics by default.

## Validation

Render the exact Argo CD target with:

```sh
kubectl kustomize applications/directus/overlays/homelab
```

The render intentionally succeeds before the SealedSecrets are generated. Until `directus-runtime-secrets` exists, the Directus pod remains pending instead of starting with an ephemeral signing secret.
