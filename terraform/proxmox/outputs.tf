output "talos_vms" {
  description = "Talos VMs managed by Terraform."
  value = {
    for key, vm in proxmox_virtual_environment_vm.talos : key => {
      vm_id = vm.vm_id
      name  = vm.name
    }
  }
}

output "control_plane_addresses" {
  description = "Control plane VM addresses reported by QEMU guest agent."
  value = {
    for key, vm in proxmox_virtual_environment_vm.talos : key => {
      vm_id = vm.vm_id
      name  = vm.name
      ipv4_addresses = sort(flatten([for addresses in vm.ipv4_addresses : [
        for address in addresses : address if !startswith(address, "127.") && !startswith(address, "169.254.") && !startswith(address, "10.244.")
      ]]))
      primary_ipv4 = try(sort(flatten([for addresses in vm.ipv4_addresses : [
        for address in addresses : address if !startswith(address, "127.") && !startswith(address, "169.254.") && !startswith(address, "10.244.")
      ]]))[0], null)
      all_ipv4_addresses = sort(flatten([for addresses in vm.ipv4_addresses : [
        for address in addresses : address if !startswith(address, "127.")
      ]]))
    } if local.talos_vms[key].role == "controlplane"
  }
}
