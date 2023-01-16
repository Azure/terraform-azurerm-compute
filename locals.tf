locals {
  is_windows    = (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "WindowsServer")) || var.is_windows_image == true
  vm_extensions = { for p in setproduct(toset([for e in var.vm_extensions : e]), toset(range(var.nb_instances))) : "${p[0].name}-${p[1]}" => { index = p[1], value = p[0] } }
}