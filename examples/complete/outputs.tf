output "debian2_availability_set_id" {
  value = module.debianservers2.availability_set_id
}

output "debian_availability_set_id" {
  value = module.debianservers.availability_set_id
}

output "debian_ip_address" {
  value = module.debianservers.public_ip_address
}

output "debian_vm_public_name" {
  value = module.debianservers.public_ip_dns_name
}

output "public_ip_dns_names" {
  value = toset(concat(
    module.ubuntuservers.public_ip_dns_name,
    module.debianservers.public_ip_dns_name,
    module.debianservers2.public_ip_dns_name,
    module.windowsservers.public_ip_dns_name,
  ))
}

output "public_ip_ids" {
  value = toset(concat(
    module.ubuntuservers.public_ip_id,
    module.debianservers.public_ip_id,
    module.debianservers2.public_ip_id,
    module.windowsservers.public_ip_id,
  ))
}

output "ubuntu_availability_set_id" {
  value = module.ubuntuservers.availability_set_id
}

output "ubuntu_identity_type" {
  value = module.ubuntuservers.vm_identity
}

output "ubuntu_ip_address" {
  value = module.ubuntuservers.public_ip_address
}

output "ubuntu_vm_public_name" {
  value = module.ubuntuservers.public_ip_dns_name
}

output "vm_identities" {
  value = merge(
    module.ubuntuservers.vm_identity,
    module.debianservers.vm_identity,
    module.debianservers2.vm_identity,
    module.windowsservers.vm_identity,
  )
}

output "vm_ids" {
  value = toset(concat(
    module.ubuntuservers.vm_ids,
    module.debianservers.vm_ids,
    module.debianservers2.vm_ids,
    module.windowsservers.vm_ids,
  ))
}

output "vm_zones" {
  value = merge(
    module.ubuntuservers.vm_zones,
    module.debianservers.vm_zones,
    module.debianservers2.vm_zones,
    module.windowsservers.vm_zones,
  )
}

output "windows_availability_set_id" {
  value = module.windowsservers.availability_set_id
}

output "windows_identity_type" {
  value = module.windowsservers.vm_identity
}

output "windows_ip_address" {
  value = module.windowsservers.public_ip_address
}

output "windows_vm_admin_password" {
  sensitive = true
  value     = local.admin_password
}

output "windows_vm_public_name" {
  value = module.windowsservers.public_ip_dns_name
}
