output "test_target_public_dns" {
  value = "${module.linuxservers.public_ip_dns_name}"
}

output "terraform_state" {
  description = "The path to the backend state file"
  value       = "${path.cwd}/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
}
