output "test_target_public_dns" {
  value = "${module.linuxservers.public_ip_dns_name}"
}
