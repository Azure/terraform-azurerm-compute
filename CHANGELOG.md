# Changelog

## [Unreleased](https://github.com/Azure/terraform-azurerm-compute/tree/HEAD)

**Merged pull requests:**

- Fix checkov issue [\#272](https://github.com/Azure/terraform-azurerm-compute/pull/272) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump github.com/Azure/terraform-module-test-helper from 0.14.0 to 0.15.0 in /test [\#271](https://github.com/Azure/terraform-azurerm-compute/pull/271) ([dependabot[bot]](https://github.com/apps/dependabot))

## [5.3.0](https://github.com/Azure/terraform-azurerm-compute/tree/5.3.0) (2023-06-06)

**Merged pull requests:**

- Bump github.com/Azure/terraform-module-test-helper from 0.13.0 to 0.14.0 in /test [\#263](https://github.com/Azure/terraform-azurerm-compute/pull/263) ([dependabot[bot]](https://github.com/apps/dependabot))
- Add tracing tags toggle variable [\#256](https://github.com/Azure/terraform-azurerm-compute/pull/256) ([lonegunmanb](https://github.com/lonegunmanb))
- Add support for `azurerm_network_interface.enable_ip_forwarding` [\#254](https://github.com/Azure/terraform-azurerm-compute/pull/254) ([lonegunmanb](https://github.com/lonegunmanb))
- Fix broken ip\_configuration when azurerm\_public\_ip is null [\#248](https://github.com/Azure/terraform-azurerm-compute/pull/248) ([Amos-85](https://github.com/Amos-85))

## [5.2.2](https://github.com/Azure/terraform-azurerm-compute/tree/5.2.2) (2023-04-18)

**Merged pull requests:**

- Bump github.com/Azure/terraform-module-test-helper from 0.9.1 to 0.13.0 in /test [\#252](https://github.com/Azure/terraform-azurerm-compute/pull/252) ([dependabot[bot]](https://github.com/apps/dependabot))
- Fix broken ip\_configuration when azurerm\_public\_ip is null [\#248](https://github.com/Azure/terraform-azurerm-compute/pull/248) ([Amos-85](https://github.com/Amos-85))

## [5.2.1](https://github.com/Azure/terraform-azurerm-compute/tree/5.2.1) (2023-04-16)

**Merged pull requests:**

- Fix broken example [\#245](https://github.com/Azure/terraform-azurerm-compute/pull/245) ([lonegunmanb](https://github.com/lonegunmanb))

## [5.2.0](https://github.com/Azure/terraform-azurerm-compute/tree/5.2.0) (2023-02-28)

**Merged pull requests:**

- Bump github.com/stretchr/testify from 1.8.1 to 1.8.2 in /test [\#241](https://github.com/Azure/terraform-azurerm-compute/pull/241) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github.com/Azure/terraform-module-test-helper from 0.8.1 to 0.9.1 in /test [\#240](https://github.com/Azure/terraform-azurerm-compute/pull/240) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github.com/gruntwork-io/terratest from 0.41.10 to 0.41.11 in /test [\#239](https://github.com/Azure/terraform-azurerm-compute/pull/239) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update versions.tf to require Terraform v1.3 [\#238](https://github.com/Azure/terraform-azurerm-compute/pull/238) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump golang.org/x/net from 0.1.0 to 0.7.0 in /test [\#237](https://github.com/Azure/terraform-azurerm-compute/pull/237) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github.com/hashicorp/go-getter/v2 from 2.1.1 to 2.2.0 in /test [\#236](https://github.com/Azure/terraform-azurerm-compute/pull/236) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github.com/hashicorp/go-getter from 1.6.1 to 1.7.0 in /test [\#235](https://github.com/Azure/terraform-azurerm-compute/pull/235) ([dependabot[bot]](https://github.com/apps/dependabot))
- Use name template variables to customize the name of each resource [\#234](https://github.com/Azure/terraform-azurerm-compute/pull/234) ([DatsloJRel](https://github.com/DatsloJRel))
- Improve separate data disk resource logic [\#233](https://github.com/Azure/terraform-azurerm-compute/pull/233) ([lonegunmanb](https://github.com/lonegunmanb))
- Pin the iterator variable to avoid concurrent test error [\#232](https://github.com/Azure/terraform-azurerm-compute/pull/232) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump github.com/gruntwork-io/terratest from 0.41.9 to 0.41.10 in /test [\#231](https://github.com/Azure/terraform-azurerm-compute/pull/231) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github.com/Azure/terraform-module-test-helper from 0.7.1 to 0.8.1 in /test [\#230](https://github.com/Azure/terraform-azurerm-compute/pull/230) ([dependabot[bot]](https://github.com/apps/dependabot))
- Create data disks and attach after VM creation by azurerm\_virtual\_machine\_data\_disk\_attachment resource. [\#227](https://github.com/Azure/terraform-azurerm-compute/pull/227) ([DatsloJRel](https://github.com/DatsloJRel))

## [5.1.0](https://github.com/Azure/terraform-azurerm-compute/tree/5.1.0) (2023-02-06)

**Merged pull requests:**

- Optionally create an availability set [\#228](https://github.com/Azure/terraform-azurerm-compute/pull/228) ([DatsloJRel](https://github.com/DatsloJRel))
- Update `README.md` with Powershell error resolution. [\#226](https://github.com/Azure/terraform-azurerm-compute/pull/226) ([DatsloJRel](https://github.com/DatsloJRel))
- Update readme to recommend new virtual machine module [\#225](https://github.com/Azure/terraform-azurerm-compute/pull/225) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump github.com/Azure/terraform-module-test-helper from 0.6.0 to 0.7.1 in /test [\#221](https://github.com/Azure/terraform-azurerm-compute/pull/221) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github.com/gruntwork-io/terratest from 0.41.7 to 0.41.9 in /test [\#219](https://github.com/Azure/terraform-azurerm-compute/pull/219) ([dependabot[bot]](https://github.com/apps/dependabot))

## [5.0.0](https://github.com/Azure/terraform-azurerm-compute/tree/5.0.0) (2023-01-16)

**Merged pull requests:**

- Adjust the "plan" input to properly set the image name and product [\#218](https://github.com/Azure/terraform-azurerm-compute/pull/218) ([AWSmith0216](https://github.com/AWSmith0216))
- Add support for multiple virtual machine extensions. [\#217](https://github.com/Azure/terraform-azurerm-compute/pull/217) ([lonegunmanb](https://github.com/lonegunmanb))
- Bump github.com/Azure/terraform-module-test-helper from 0.4.0 to 0.6.0 in /test [\#216](https://github.com/Azure/terraform-azurerm-compute/pull/216) ([dependabot[bot]](https://github.com/apps/dependabot))
- Bump github.com/gruntwork-io/terratest from 0.41.6 to 0.41.7 in /test [\#215](https://github.com/Azure/terraform-azurerm-compute/pull/215) ([dependabot[bot]](https://github.com/apps/dependabot))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
