locals {
  windows_vm_ids = [for i in range(var.nb_instances) : "windows-${i}"]
  linux_vm_ids   = [for i in range(var.nb_instances) : "linux-${i}"]
}

data "null_data_source" "extensions" {
  for_each = nonsensitive(local.vm_extensions)

  inputs = {
    virtual_machine_id = (var.is_windows_image || contains(tolist([
      var.vm_os_simple, var.vm_os_offer
    ]), "WindowsServer")) ? local.windows_vm_ids[each.value.index] : local.linux_vm_ids[each.value.index]
  }
}