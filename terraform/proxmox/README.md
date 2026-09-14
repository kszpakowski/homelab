# Homelab Proxmox Terraform

Terraform configuration for the Talos Kubernetes virtual machines running on a single Proxmox VE node.

The project manages six Talos VMs on Proxmox node `pve`:

| Key | VM ID | Proxmox name | Role |
| --- | ---: | --- | --- |
| `control_plane_1` | 100 | `talos-90f-dtn` | Control plane |
| `control_plane_2` | 105 | `talos-55b-wwu` | Control plane |
| `control_plane_3` | 106 | `talos-v6x-q0o` | Control plane |
| `worker_1` | 101 | `talos-fd0-wmu` | Worker |
| `worker_2` | 102 | `talos-ifo-72a` | Worker |
| `worker_3` | 103 | `talos-fdj-mp6` | Worker |

All VM definitions live in `locals.tf`. Shared defaults such as CPU, memory, boot disk size, storage, and QEMU guest agent settings are defined in `local.vm_defaults`; per-node values are defined in `local.talos_vm_overrides`.

The current defaults are:

- 4 vCPU cores
- 8 GiB RAM
- 100 GiB boot disk on `local-lvm`
- `vmbr0` network bridge with firewall enabled
- QEMU guest agent enabled with `wait_for_ip`
- Talos `v1.13.10` image from Talos Image Factory

The cluster has three control-plane VMs for etcd quorum, but all VMs still run on one physical Proxmox host. This protects the Kubernetes control plane from a single VM failure, not from a failure of the `pve` host.

## Repository layout

```text
.
├── locals.tf                    # VM inventory and default hardware settings
├── vms.tf                       # Proxmox VM and Talos image resources
├── provider.tf                  # Proxmox provider configuration
├── variables.tf                 # Provider and Talos image variables
├── outputs.tf                   # VM inventory and control-plane IP outputs
├── scripts/
│   ├── import-existing-vms      # One-time import helper for existing VMs
│   └── tf-with-keychain         # Terraform wrapper reading the API token from macOS Keychain
├── backend.tf.example           # Optional remote backend template
├── backend.hcl.example          # Optional remote backend config template
└── terraform.auto.tfvars.example
```

## Requirements

- Terraform `>= 1.5.7`
- Proxmox VE reachable at `https://192.168.1.2:8006/`
- Proxmox node named `pve`
- macOS Keychain access for the Proxmox API token
- Proxmox storage:
  - `local` with `import` content enabled
  - `local-lvm` for VM disks
- Network bridge `vmbr0`

The configuration uses the `bpg/proxmox` provider.

## Proxmox API token

Terraform should be run through `scripts/tf-with-keychain`. The wrapper reads the Proxmox API token from macOS Keychain and exports it as `PROXMOX_VE_API_TOKEN` for the provider.

The expected Keychain item is:

| Field | Value |
| --- | --- |
| Service | `homelab/proxmox/terraform-api-token` |
| Account | `terraform@pve!homelab` |
| Password | `terraform@pve!homelab=SECRET` |

Create a dedicated Proxmox user and token. With privilege separation enabled, Proxmox evaluates the effective permissions as the intersection of the user permissions and token permissions, so assign ACLs to both the user and the token.

Example Proxmox CLI setup:

```sh
pveum user add terraform@pve --comment 'Terraform automation'

pveum role add TerraformHomelab --privs 'Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit SDN.Audit SDN.Use Sys.Audit Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.GuestAgent.Audit VM.Migrate VM.PowerMgmt'

pveum acl modify / --users terraform@pve --roles TerraformHomelab
pveum acl modify /vms --users terraform@pve --roles TerraformHomelab
pveum acl modify /storage/local --users terraform@pve --roles TerraformHomelab
pveum acl modify /storage/local-lvm --users terraform@pve --roles TerraformHomelab
pveum acl modify /sdn/zones/localnetwork/vmbr0 --users terraform@pve --roles TerraformHomelab

pveum user token add terraform@pve homelab --privsep 1

pveum acl modify / --tokens 'terraform@pve!homelab' --roles TerraformHomelab
pveum acl modify /vms --tokens 'terraform@pve!homelab' --roles TerraformHomelab
pveum acl modify /storage/local --tokens 'terraform@pve!homelab' --roles TerraformHomelab
pveum acl modify /storage/local-lvm --tokens 'terraform@pve!homelab' --roles TerraformHomelab
pveum acl modify /sdn/zones/localnetwork/vmbr0 --tokens 'terraform@pve!homelab' --roles TerraformHomelab
```

The token creation command prints the secret only once. Store the full provider token value in Keychain:

```sh
security add-generic-password \
  -a 'terraform@pve!homelab' \
  -s 'homelab/proxmox/terraform-api-token' \
  -w 'terraform@pve!homelab=SECRET' \
  -U
```

Do not commit Proxmox tokens to `.tf`, `.tfvars`, `.env`, shell history snippets, or Terraform state files.

## Storage setup

The Talos image is downloaded with `proxmox_download_file` as `content_type = "import"` and then used as a VM disk import source. Proxmox storage `local` must allow the `import` content type.

Check the current storage configuration on the Proxmox host:

```sh
grep -A8 '^dir: local$' /etc/pve/storage.cfg
```

If `import` is missing, add it while preserving the existing content types. For the default local storage this is usually:

```sh
pvesm set local --content backup,import,iso,vztmpl
```

If your `local` storage has additional content types, keep them and append `import` to the existing list.

## Terraform state

Local Terraform state is ignored by Git. Use local state only for initial setup or one-off homelab work.

For long-term use, store state outside the Kubernetes cluster and outside the Proxmox host managed by this project. A private S3 bucket is a good default when configured with:

- versioning
- Block Public Access
- server-side encryption
- Terraform lockfile support with `use_lockfile = true`
- separate IAM permissions for operators and CI

To migrate to the example S3 backend:

```sh
cp backend.tf.example backend.tf
cp backend.hcl.example backend.hcl
# Edit backend.hcl. It is ignored by Git.
./scripts/tf-with-keychain init -migrate-state -backend-config=backend.hcl
```

HCP Terraform is also a good option. Avoid storing the only copy of Terraform state inside the Kubernetes cluster that this project manages.

## Importing existing VMs

VMs 100-103 were created before this Terraform project. Import them once before the first apply:

```sh
./scripts/tf-with-keychain init
./scripts/import-existing-vms
```

VMs 105 and 106 are regular Terraform-managed VMs and are created by `terraform apply` if they do not already exist.

## Planning and applying changes

Use the wrapper for all Terraform commands:

```sh
./scripts/tf-with-keychain init
./scripts/tf-with-keychain plan -out=talos-vms.tfplan
./scripts/tf-with-keychain apply talos-vms.tfplan
```

After apply, check that the state is clean:

```sh
./scripts/tf-with-keychain plan -no-color
```

Expected result:

```text
No changes. Your infrastructure matches the configuration.
```

To print the managed VM inventory:

```sh
./scripts/tf-with-keychain output talos_vms
```

To print control-plane addresses reported by the QEMU guest agent:

```sh
./scripts/tf-with-keychain output control_plane_addresses
```

## Talos node initialization

Terraform creates and configures the Proxmox VMs. It does not apply Talos machine configuration and does not bootstrap Kubernetes.

For newly created control-plane VMs:

1. Wait until the VM is reachable and the QEMU guest agent reports an IP address.
2. Apply the current Talos control-plane machine config from the Talos configuration repository.
3. Do not run `talosctl bootstrap` for additional control-plane nodes in an existing cluster.
4. Verify Talos health and etcd membership after the node joins.

## Dynamic disks managed by Proxmox CSI

Worker nodes can have additional disks attached dynamically by the Proxmox CSI storage class. Those disks are runtime storage attachments, not boot disks owned by this Terraform project.

The VM resource uses:

```hcl
lifecycle {
  prevent_destroy = true
  ignore_changes  = [disk]
}
```

This prevents Terraform from planning changes to disks after import or creation. The boot disk remains declared as `scsi0`; dynamic CSI disks should be managed by Kubernetes and Proxmox CSI.

If an imported worker VM has stale empty disk entries in Terraform state, the Proxmox provider may fail during an otherwise unrelated VM update with an error similar to:

```text
Defined disk interface not supported. Interface was , but only [ide sata scsi virtio] are supported
```

Before editing state, create a backup:

```sh
terraform state pull > terraform.tfstate.backup-before-disk-state-cleanup-$(date +%Y%m%d%H%M%S)
```

Then inspect the state and remove only empty disk entries that have no `interface` and no `path_in_datastore`. Do not remove real `scsiX` disks reported by Proxmox.

## Updating VM definitions

Edit VM definitions in `locals.tf`:

- change shared defaults in `local.vm_defaults`
- change per-node values in `local.talos_vm_overrides`
- keep VM keys stable unless you intend to move Terraform state
- keep VM IDs stable for existing VMs

Run a plan before applying any change:

```sh
./scripts/tf-with-keychain plan -no-color
```

Review plans carefully when changing imported VMs, especially workers with dynamically attached storage.

## References

- [bpg/proxmox provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Proxmox VM resource](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm)
- [Proxmox user and token management](https://pve.proxmox.com/pve-docs/pveum.1.html)
- [Terraform S3 backend](https://developer.hashicorp.com/terraform/language/backend/s3)
