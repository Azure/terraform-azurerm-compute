output "vm_extensions" {
  value     = local.vm_extensions
  sensitive = true
}

output "generated_extensions" {
  value     = data.null_data_source.extensions
  sensitive = true
}