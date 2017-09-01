output "azurerm_vm_ids" {
  description = "Virtual machine ids created."
  value = "${var.vm_os_simple == "Windows" ? azurerm_virtual_machine.vm-windows.*.id : azurerm_virtual_machine.vm-linux.*.id}}"
}

output "azurerm_network_security_group_id" {
  description = "id of the security group provisioned"
  value = "${azurerm_network_security_group.vm.id}"
}

output "azurerm_network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value = "${azurerm_network_interface.vm.*.id}"
}

output "azurerm_network_interface_private_ip"{
  value = "${azurerm_network_interface.vm.*.private_ip_address}"
}

output "azurerm_public_ip_id" {
  description = "id of the public ip address provisoned."
  value = "${azurerm_public_ip.vm.id}"
}

output "azurerm_public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value = "${azurerm_public_ip.vm.ip_address}"
}

output "azurerm_public_ip_dns_name" {
  description = "fqdn to connect to the first vm   provisioned."
  value = "${azurerm_public_ip.vm.fqdn}"
}

output "azurerm_availability_set_id" {
  description = "id of the availability set where the vms are provisioned."
  value = "${azurerm_availability_set.vm.id}"
}

output "azurerm_storage_account_id" {
  description = "id of the storage account where the vm vhds are stored."
  value = "${azurerm_storage_account.vm.id}"
}
