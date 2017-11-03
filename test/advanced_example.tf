module "linuxservers" {
  source              = "../"
  resource_group_name = "terraform-advancedvms"
  location            = "westus2"
  vm_hostname         = "mylinuxvm"
  nb_public_ip        = "0"
  remote_port         = "22"
  nb_instances        = "2"
  vm_os_publisher     = "Canonical"
  vm_os_offer         = "UbuntuServer"
  vm_os_sku           = "14.04.2-LTS"
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  boot_diagnostics    = "true"
  delete_os_disk_on_termination = "true"
  data_disk           = "true"
  data_disk_size_gb   = "64"
  data_sa_type        = "Premium_LRS"

  tags                = {
    environment = "dev"
    costcenter  = "it"
  }
}

module "windowsservers" {
  source              = "../"
  resource_group_name = "terraform-advancedvms"
  location            = "westus2"
  vm_hostname         = "mywinvm"
  admin_password      = "ComplxP@ssw0rd!"
  public_ip_dns       = ["winterravmip","winterravmip1"]
  nb_public_ip        = "2"
  remote_port         = "3389"
  nb_instances        = "2"
  vm_os_publisher     = "MicrosoftWindowsServer"
  vm_os_offer         = "WindowsServer"
  vm_os_sku           = "2012-R2-Datacenter"
  vm_size             = "Standard_DS2_V2"
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
}

module "network" {
  source = "Azure/network/azurerm"
  location = "westus2"
  resource_group_name = "terraform-advancedvms"
}

output "linux_vm_private_ips" {
  value = "${module.linuxservers.network_interface_private_ip}"
}

output "windows_vm_public_name"{
  value = "${module.windowsservers.public_ip_dns_name}"
}

output "windows_vm_public_ip" {
  value = "${module.windowsservers.public_ip_address}"
}

output "windows_vm_private_ips" {
  value = "${module.windowsservers.network_interface_private_ip}"
}
