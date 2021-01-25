output "vm_ids" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine.vm.*.id)
}

output "network_security_group_id" {
  description = "id of the security group provisioned"
  value       = azurerm_network_security_group.vm.id
}

output "network_security_group_name" {
  description = "name of the security group provisioned"
  value       = azurerm_network_security_group.vm.name
}

output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = azurerm_network_interface.vm.*.id
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.vm.*.private_ip_address
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.vm.*.id
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = data.azurerm_public_ip.vm.*.ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.vm.*.fqdn
}
