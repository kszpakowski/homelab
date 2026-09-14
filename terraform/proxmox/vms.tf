resource "proxmox_download_file" "talos_qcow2" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node_name

  file_name = "talos-${var.talos_version}-${var.talos_schematic_id}-metal-amd64.qcow2"
  url       = "https://factory.talos.dev/image/${var.talos_schematic_id}/${var.talos_version}/metal-amd64.qcow2"
}

resource "proxmox_virtual_environment_vm" "talos" {
  for_each = local.talos_vms

  node_name   = var.proxmox_node_name
  vm_id       = each.value.vm_id
  name        = each.value.name
  description = each.value.description

  started = true
  on_boot = true

  agent {
    enabled = true
    wait_for_ip {
      disabled = !each.value.wait_for_ip
      ipv4     = each.value.wait_for_ip
    }
  }

  cpu {
    cores   = each.value.cpu_cores
    sockets = each.value.cpu_sockets
    type    = each.value.cpu_type
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = each.value.boot_disk_id
    import_from  = each.value.import_from_image ? proxmox_download_file.talos_qcow2.id : null
    interface    = "scsi0"
    iothread     = true
    size         = each.value.disk_size
  }

  network_device {
    bridge      = "vmbr0"
    firewall    = true
    mac_address = each.value.mac_address
  }

  operating_system {
    type = "l26"
  }

  boot_order      = ["scsi0", "net0"]
  scsi_hardware   = "virtio-scsi-single"
  stop_on_destroy = true

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [disk]
  }
}
