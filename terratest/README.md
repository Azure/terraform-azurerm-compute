# Compute Example

Use terraform azure module "compute" to deploy one or more virtual machines on azure. Then use terratest to ssh to virtual machines.

## Compute

These terraform files enable users to deploy one or more virtual machines on azure, as well as virtual network. To use these files, you should provide path to ssh public key file in [compute/terraform.tfvars](/terratest/compute/terraform.tfvars). You can just test the infrastructure code manually without terratest.

## SSH

This folder includes three files, but two of them are not used. Most importantly, [ssh/terraform_ssh_example_test.go](/terratest/ssh/terraform_ssh_example_test.go) is the main go test file which represents the whole process of testing the module. First, it uses terraform compute module to deploy virtual machines on azure. After that, it calls functions from terratest ssh section, so as to ssh to these virtual machines and check whether they are running properly. Next, everything will be cleaned up after validation. Of course you can write your own test code, or even take advantage of deprecated methods. Finally, in order to make this program work, you should provide your own ssh private key.

## Running this module manually

1. Sign up for [Azure](https://portal.azure.com/).

1. Configure your Azure credentials. For instance, you may use [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and execute `az login`.

1. Install [Terraform](https://www.terraform.io/) and make sure it's on your `PATH`.

1. Fill in blank of your ssh public key in [compute/terraform.tfvars](/terratest/compute/terraform.tfvars) and make sure your configuration is correct.

1. Direct to folder [compute](/terratest/compute) and run `terraform init`.

1. Run `terraform apply`.

1. When you're done, run `terraform destroy`.

## Running automated tests against this module

1. Sign up for [Azure](https://portal.azure.com/).

1. Configure your Azure credentials. For instance, you may use [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and execute `az login`.

1. Install [Terraform](https://www.terraform.io/) and make sure it's on your `PATH`.

1. Install [Golang](https://golang.org/) and make sure this code is checked out into your `GOPATH`.

1. Fill in blank of your ssh public key in [compute/terraform.tfvars](/terratest/compute/terraform.tfvars) and make sure your configuration is correct.

1. Direct to folder [ssh](/terratest/ssh) and make sure all packages are installed, such as executing `go get github.com/gruntwork-io/terratest/modules/terraform`, etc.

1. Run `go test -timeout timelimit -args username path/to/your/private/key`. For example, `go test -timeout 20m -args azureuser id_rsa`. Be aware that `-timeout` is set to 10 minutes by default and can be omitted, but it should be defined before `-args`.

## Reference

[Terraform Azure Compute Module](https://registry.terraform.io/modules/Azure/compute/azurerm/)

[Terratest SSH Source Code](https://github.com/gruntwork-io/terratest/blob/master/test/terraform_ssh_example_test.go)

[SSH Golang Document](https://godoc.org/golang.org/x/crypto/ssh)

[SSH Client Connection Example in Golang](http://blog.ralch.com/tutorial/golang-ssh-connection/)

[Azure Linux Virtual Machine Document](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/)

[Azure Virtual Network Document](https://docs.microsoft.com/en-us/azure/virtual-network/)