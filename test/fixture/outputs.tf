output "ubuntu_vm_public_name" {
  value = module.ubuntuservers.public_ip_dns_name
}

output "debian_vm_public_name" {
  value = "${module.debianservers.public_ip_dns_name}"
}

output "ubuntu_ip_address" {
  value = module.ubuntuservers.public_ip_address
}

output "debian_ip_address" {
  value = "${module.debianservers.public_ip_address}"
}
