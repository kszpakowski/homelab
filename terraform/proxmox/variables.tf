variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint without /api2/json."
  type        = string
  default     = "https://192.168.1.2:8006/"
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for the current self-signed Proxmox certificate."
  type        = bool
  default     = true
}

variable "proxmox_node_name" {
  description = "Proxmox node on which the Talos VMs run."
  type        = string
  default     = "pve"
}

variable "talos_version" {
  description = "Talos disk image version used for new control plane VMs."
  type        = string
  default     = "v1.13.10"
}

variable "talos_schematic_id" {
  description = "Talos Image Factory schematic containing qemu-guest-agent."
  type        = string
  default     = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

