locals {
  vm_defaults = {
    cpu_cores    = 4
    cpu_sockets  = 1
    cpu_type     = "x86-64-v2-AES"
    memory       = 8192
    wait_for_ip  = true
    mac_address  = null
    description  = null
    disk_size    = 100
    boot_disk_id = "local-lvm"
  }

  talos_vm_overrides = {
    control_plane_1 = {
      vm_id             = 100
      name              = "talos-90f-dtn"
      role              = "controlplane"
      description       = "Control plane node"
      import_from_image = false
    }
    worker_1 = {
      vm_id             = 101
      name              = "talos-fd0-wmu"
      role              = "worker"
      description       = null
      import_from_image = false
    }
    worker_2 = {
      vm_id             = 102
      name              = "talos-ifo-72a"
      role              = "worker"
      description       = null
      import_from_image = false
    }
    worker_3 = {
      vm_id             = 103
      name              = "talos-fdj-mp6"
      role              = "worker"
      description       = null
      import_from_image = false
    }
    control_plane_2 = {
      vm_id             = 105
      name              = "talos-55b-wwu"
      role              = "controlplane"
      description       = "Control plane node"
      import_from_image = true
    }
    control_plane_3 = {
      vm_id             = 106
      name              = "talos-v6x-q0o"
      role              = "controlplane"
      description       = "Control plane node"
      import_from_image = true
    }
  }

  talos_vms = {
    for name, vm in local.talos_vm_overrides : name => merge(local.vm_defaults, vm)
  }
}
