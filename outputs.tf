output "azurerm_vm_names" {
  value = "${var.vm_os_simple == "Windows" ? azurerm_virtual_machine.vm-windows.name : azurerm_virtual_machine.vm-linux.name}"
}

output "azurerm_vm_ids" {
  value = "${var.vm_os_simple == "Windows" ? azurerm_virtual_machine.vm-windows.id : azurerm_virtual_machine.vm-linux.id}}"
}