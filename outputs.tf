output "availability_set_id" {
  description = "Id of the availability set where the vms are provisioned. If `var.zones` is set, this output will return empty string."
  value       = join("", azurerm_availability_set.vm[*].id)
}

output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = azurerm_network_interface.vm[*].id
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.vm[*].private_ip_address
}

output "network_security_group_id" {
  description = "id of the security group provisioned"
  value       = azurerm_network_security_group.vm.id
}

output "network_security_group_name" {
  description = "name of the security group provisioned"
  value       = azurerm_network_security_group.vm.name
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = data.azurerm_public_ip.vm[*].ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.vm[*].fqdn
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.vm[*].id
}

output "vm_identity" {
  description = "map with key `Virtual Machine Id`, value `list of identity` created for the Virtual Machine."
  value       = zipmap(concat([for m in azurerm_virtual_machine.vm_windows : m.id], [for m in azurerm_virtual_machine.vm_linux : m.id]), concat(azurerm_virtual_machine.vm_windows[*].identity, azurerm_virtual_machine.vm_linux[*].identity))
}

output "vm_ids" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_virtual_machine.vm_windows[*].id, azurerm_virtual_machine.vm_linux[*].id)
}

output "vm_zones" {
  description = "map with key `Virtual Machine Id`, value `list of the Availability Zone` which the Virtual Machine should be allocated in."
  value       = zipmap(concat(azurerm_virtual_machine.vm_windows[*].id, azurerm_virtual_machine.vm_linux[*].id), concat(azurerm_virtual_machine.vm_windows[*].zones, azurerm_virtual_machine.vm_linux[*].zones))
}