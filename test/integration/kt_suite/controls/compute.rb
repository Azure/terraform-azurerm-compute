

resource_group_name = attribute(
  "resource_group_name",
  description: "The Terraform output resource group name",
)

control 'compute' do
  
  # Test the output of the tfstate
  describe resource_group_name do
      it { should_not be_empty }
  end
  
  # Test the Azure VM Resource
  unless resource_group_name.empty?
    describe azurerm_virtual_machine(resource_group: resource_group_name, name: 'mylinvm0') do
      it                                { should exist }
      its('type')                       { should eq 'Microsoft.Compute/virtualMachines' }
      its('location')                   { should eq 'westus2' }

      its('properties.hardwareProfile.vmSize') { should eq 'Standard_DS1_V2'}

      # Ensure that the machine has been created from the correct image
      its('properties.storageProfile.imageReference.publisher') { should  eq 'credativ' }
      its('properties.storageProfile.imageReference.offer') { should  eq 'Debian' }
      its('properties.storageProfile.imageReference.sku') { should eq '8' }
    
      # Check the type of the machine and the disk that it is using
      its('properties.storageProfile.osDisk.osType') { should eq 'Linux' }
      its('properties.storageProfile.osDisk.name') { should eq 'osdisk-mylinvm-0' }
      its('properties.storageProfile.osDisk.caching') { should cmp 'ReadWrite' }
      its('properties.storageProfile.osDisk.diskSizeGB') { should be >= 25 }
      its('properties.storageProfile.osDisk.createOption') { should cmp 'FromImage' }
      its('properties.storageProfile.osDisk.managedDisk.storageAccountType') { should eq 'Premium_LRS'}
    
      # Check the data disk
      its('properties.storageProfile.dataDisks.count') { should eq 0 }
    
      # Check the admin username for the machine and the hostname
      its('properties.osProfile.adminUsername') { should cmp 'azureuser' }
      its('properties.osProfile.computerName') { should eq 'mylinvm0' }
  
      # Only one ssh keys should be assigned to the machine
      its('properties.osProfile.linuxConfiguration.ssh.publicKeys.count') { should eq 1 }
      its('properties.osProfile.linuxConfiguration.disablePasswordAuthentication') { should cmp 'true' }
    
      # Check that the machine has a NIC and that the correct one is connected
      its('properties.networkProfile.networkInterfaces.count') { should eq 1 }
    
      # The machine should have boot diagnostics enabled
      its('properties.diagnosticsProfile.bootDiagnostics.enabled') { should cmp 'false' }
    end
  end  
end