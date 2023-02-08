output "data_disk_list" {
  value = local.data_disk_list
}

output "data_disk_map" {
  value = local.data_disk_map
}

output "data_disk_map_linux" {
  value = local.data_disk_map_linux
}

output "data_disk_map_windows" {
  value = local.data_disk_map_windows
}

output "extra_data_disk_list" {
  value = local.extra_disk_list
}

output "extra_disk_map" {
  value = local.extra_disk_map
}

output "extra_disk_map_linux" {
  value = local.extra_disk_map_linux
}

output "extra_disk_map_windows" {
  value = local.extra_disk_map_windows
}

output "generated_extensions" {
  value     = data.null_data_source.extensions
  sensitive = true
}

output "nested_data_disk_list" {
  value = local.nested_data_disk_list
}

output "nested_extra_data_disk_list" {
  value = local.nested_extra_data_disk_list
}

output "vm_extensions" {
  value     = local.vm_extensions
  sensitive = true
}