resource_group_name = "dummy"
vnet_subnet_id      = "dummy"
vm_extensions = [
  {
    "name" : "hostname"
    "publisher" : "Microsoft.Azure.Extensions",
    "type" : "CustomScript",
    "type_handler_version" : "2.0",
    "settings" : "{\"commandToExecute\": \"hostname && uptime\"}",
  },
  {
    "name" : "AzureMonitorLinuxAgent",
    "publisher" : "Microsoft.Azure.Monitor",
    "type" : "AzureMonitorLinuxAgent",
    "type_handler_version" : "1.21",
    "auto_upgrade_minor_version" : true
  },
]