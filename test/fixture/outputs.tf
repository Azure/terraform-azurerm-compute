output "ubuntu_vm_public_name" {
  value = module.ubuntuservers.public_ip_dns_name
}

output "ubuntu_vm_names" {
  value = module.ubuntuservers.vm_names
}

output "debian_vm_public_name" {
  value = module.debianservers.public_ip_dns_name
}

output "debian_vm_names" {
  value = module.debianservers.vm_names
}

output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}

output "windows_vm_names" {
  value = module.windowsservers.vm_names
}

output "ubuntu_ip_address" {
  value = module.ubuntuservers.public_ip_address
}

output "debian_ip_address" {
  value = module.debianservers.public_ip_address
}

output "windows_ip_address" {
  value = module.windowsservers.public_ip_address
}

output "ubuntu_identity_type" {
  value = module.ubuntuservers.vm_identity
}

output "windows_identity_type" {
  value = module.windowsservers.vm_identity
}
