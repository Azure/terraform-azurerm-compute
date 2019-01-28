output "ubuntu_ip_address" {
  value = "${module.ubuntuservers.public_ip_address}"
}

output "debian_ip_address" {
  value = "${module.debianservers.public_ip_address}"
}
