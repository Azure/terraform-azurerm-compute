locals {
  data_disk_list = flatten([
    for host_number in range(var.nb_instances) : [
      for data_disk_number in range(var.nb_data_disk) : {
        key         = join("-", ["datadisk", host_number, data_disk_number])
        name        = var.group_by_vm_instance ? join("-", [var.vm_hostname, host_number, "datadisk", data_disk_number]) : join("-", [var.vm_hostname, "datadisk", host_number, data_disk_number])
        host_number = host_number
        disk_number = data_disk_number
      }
    ]
  ])
  data_disk_map         = { for obj in local.data_disk_list : obj.key => obj if !var.nested_data_disks }
  data_disk_map_linux   = { for obj in local.data_disk_list : obj.key => obj if !var.nested_data_disks && !local.is_windows }
  data_disk_map_windows = { for obj in local.data_disk_list : obj.key => obj if !var.nested_data_disks && local.is_windows }
  extra_disk_list = flatten([
    for host_number in range(var.nb_instances) : [
      for extra_disk in var.extra_disks : {
        key         = join("-", ["extradisk", host_number, extra_disk.name])
        name        = var.group_by_vm_instance ? join("-", [var.vm_hostname, host_number, "extradisk", extra_disk.name]) : join("-", [var.vm_hostname, "extradisk", host_number, extra_disk.name])
        host_number = host_number
        disk_number = index(var.extra_disks, extra_disk)
        disk_name   = extra_disk.name
        disk_size   = extra_disk.size
      }
    ]
  ])
  extra_disk_map              = { for obj in local.extra_disk_list : obj.key => obj if !var.nested_data_disks }
  extra_disk_map_linux        = { for obj in local.extra_disk_list : obj.key => obj if !var.nested_data_disks && !local.is_windows }
  extra_disk_map_windows      = { for obj in local.extra_disk_list : obj.key => obj if !var.nested_data_disks && local.is_windows }
  is_windows                  = (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer")) || var.is_windows_image == true
  nested_data_disk_list       = var.nested_data_disks ? range(var.nb_data_disk) : []
  nested_extra_data_disk_list = var.nested_data_disks ? var.extra_disks : []
  vm_extensions               = { for p in setproduct(toset([for e in var.vm_extensions : e]), toset(range(var.nb_instances))) : "${p[0].name}-${p[1]}" => { index = p[1], value = p[0] } }
}