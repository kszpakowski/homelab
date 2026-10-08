# Immich

The homelab ApplicationSet discovers `applications/immich/overlays/homelab`
when these files are committed and pushed. No ApplicationSet changes are needed.

The installation uses Immich server and machine learning v3.3.0, persistent
Valkey job queues, and CloudNativePG 1.28 with PostgreSQL 18 and VectorChord.
The database bootstrap creates VectorChord (including pgvector) and earthdistance
before Immich connects. Requires Kubernetes image-volume support; the homelab
currently runs Kubernetes 1.36.3.

## Storage and ingress

All volumes use `proxmox-data-ext4` and ReadWriteOnce access:

| Data | Capacity |
| --- | --- |
| Originals, thumbnails, encoded videos, and Immich database dumps | 250 GiB |
| PostgreSQL | 20 GiB |
| Machine-learning model cache | 10 GiB |
| Valkey queues (AOF, fsync every second) | 1 GiB |

The workloads use one replica and Recreate updates to avoid simultaneous mounts
of a ReadWriteOnce volume. Library, queue, and database resources are protected
from automatic Argo CD pruning and application deletion. The underlying storage
class has reclaim policy Delete: manually deleting a PVC can still destroy data.
Persistence is not a backup; keep independent backups of both photos and database.

Traefik serves `https://immich.homelab.kszpakowski.com`, with a certificate from
the `letsencrypt` ClusterIssuer and DNS managed by external-dns. The entire root
path goes to Immich, including its API and mobile uploads.

## Upload processing

The server requests 2 GiB memory and has a 5 GiB limit. CPU_CORES is fixed at 2,
and thumbnail generation, video conversion, smart search, face detection, and OCR
run one job at a time; metadata extraction runs two. These settings reduce memory
spikes during bulk uploads on the 8 GiB nodes. The original 4 GiB limit was hit
during photo processing (OOMKilled), causing repeated server restarts.

## Pocket ID

The existing Pocket ID operator registers the `immich` OIDC client and creates
`immich-oidc` in the Immich namespace. The server waits for this Secret; an init
container reads its `instance_url`, `client_id`, and `client_secret` keys and writes
an Immich JSON config into an in-memory volume. Credentials never enter Git.

The installed operator supports a single redirect URL. The callback wildcard is
restricted to `https://immich.homelab.kszpakowski.com/**` to support web login,
account linking, and mobile login. Mobile login uses Immich's HTTPS redirect
endpoint. If the operator gains multiple callback support, replace the wildcard
with the exact `/auth/login`, `/user-settings`, and `/api/oauth/mobile-redirect`
URLs.

On the first visit, create the initial Immich administrator using the setup
screen. Password login stays enabled for bootstrap and recovery, and the login
screen offers **Sign in with Pocket ID**. OAuth automatically registers Pocket ID
users; access is not restricted to a particular Pocket ID group.

Immich's config-file mode disables editing system settings in the UI. Manage
settings in `overlays/homelab/oauth-patch.yaml`. Restart the server after changes
to the operator-generated credentials so the init container rebuilds the config:

```sh
kubectl -n immich rollout restart deployment/immich-server
```

## Validation

```sh
kustomize build applications/immich/overlays/homelab
kubectl apply --dry-run=server -f <(kustomize build applications/immich/overlays/homelab)
```

Server dry run requires the Immich namespace to exist. During initial validation,
all 12 resource schemas were accepted using a temporary rendered copy targeting
an existing namespace; no resources were deployed. Runtime provisioning, image
pulls, TLS issuance, and OIDC sign-in must be verified after Argo CD sync.
