# Terraform Azure Windows Virtual Machine Module

Production-grade Terraform module for managing Azure Windows Virtual Machines with comprehensive security, monitoring, and operational features.

## Features

- **Windows Server Support**: Windows Server 2019/2022 Datacenter editions
- **Flexible VM Sizing**: Configurable VM sizes from Standard_B2s to enterprise-grade SKUs
- **Network Configuration**: Network interface with private IP, optional public IP
- **Encrypted Managed Disks**: OS disk with encryption + optional data disks
- **Security Hardening**: Secure Boot and vTPM for Generation 2 VMs
- **Boot Diagnostics**: Integrated with Azure Storage for troubleshooting
- **Managed Identity**: System-assigned managed identity for Azure resource access
- **Availability Options**: Support for availability zones and availability sets
- **VM Extensions**: Azure Monitor Agent, Dependency Agent, Antimalware, BGInfo
- **Azure Hybrid Benefit**: Licensing support for cost optimization
- **Automated Patching**: Configurable patch mode and assessment
- **Comprehensive Validation**: Input validation for all variables
- **Full Test Coverage**: Terraform native tests for reliability
- **terraform-namer Integration**: Consistent naming and tagging

## Quick Start

```hcl
module "windows_vm" {
  source = "path/to/terraform-azurerm-windows-virtual-machine"

  # Naming variables
  contact     = "admin@company.com"
  environment = "dev"
  location    = "centralus"
  repository  = "infrastructure"
  workload    = "app"

  # Resource configuration
  resource_group_name = "rg-app-cu-dev-kmi-0"
  subnet_id           = "/subscriptions/.../subnets/subnet-app"
  vm_size             = "Standard_D2s_v3"
  admin_username      = "azureadmin"
  admin_password      = "P@ssw0rd1234!" # Use Azure Key Vault in production

  # Boot diagnostics
  boot_diagnostics_storage_account_uri = "https://stdiag.blob.core.windows.net/"

  # Optional: Data disks
  data_disks = [
    {
      disk_size_gb         = 100
      lun                  = 0
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
    }
  ]

  # Optional: VM extensions
  enable_azure_monitor_agent = true
  enable_antimalware         = true
}
```

## Important Security Notes

- **Store Passwords Securely**: Use Azure Key Vault for admin passwords, not in Terraform code
- **Enable Azure Defender**: Enable Azure Defender for Servers for enhanced security
- **Configure NSG Rules**: Apply Network Security Group rules on the subnet
- **Enable Backup**: Configure Azure Backup for production VMs
- **Use Managed Identity**: Prefer managed identity over stored credentials
- **Review Extensions**: Enable only required VM extensions

## Testing

This module uses Terraform native tests for validation:

```bash
# Run all tests
make test

# Run specific test file
terraform test -filter=tests/basic.tftest.hcl
```

See [tests/README.md](tests/README.md) for detailed testing documentation.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
# =============================================================================
# Example: Windows Virtual Machine with Standard Configuration
# =============================================================================
#
# This example demonstrates how to create a Windows Server 2022 VM with:
# - Standard D2s_v3 VM size
# - Encrypted OS disk (Premium SSD)
# - One data disk (100GB)
# - Azure Monitor Agent and Antimalware extensions
# - Boot diagnostics enabled
# - System-assigned managed identity
# - Secure Boot and vTPM enabled (Generation 2 VM)
#

module "windows_vm" {
  source = "../.."

  # Required: Naming variables
  contact     = "admin@example.com"
  environment = "dev"
  location    = "centralus"
  repository  = "terraform-azurerm-windows-virtual-machine"
  workload    = "app"

  # Required: Resource configuration
  resource_group_name = "rg-example-cu-dev-kmi-0"
  subnet_id           = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-app"

  # Required: VM configuration
  vm_size        = "Standard_D2s_v3"
  admin_username = "azureadmin"
  # Note: In production, store passwords in Azure Key Vault
  admin_password = "P@ssw0rd1234!SecurePassword"

  # Required: Boot diagnostics
  boot_diagnostics_storage_account_uri = "https://stdiagexample.blob.core.windows.net/"

  # Optional: OS Image (Windows Server 2022 Generation 2)
  os_image_sku = "2022-datacenter-g2"

  # Optional: OS Disk configuration
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 128

  # Optional: Data disks
  data_disks = [
    {
      disk_size_gb         = 100
      lun                  = 0
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
    }
  ]

  # Optional: Security configuration (Gen2 VM)
  enable_secure_boot = true
  enable_vtpm        = true

  # Optional: Availability
  availability_zone = "1"

  # Optional: VM Extensions
  enable_azure_monitor_agent = true
  enable_antimalware         = true
  enable_bginfo              = true
  enable_dependency_agent    = false

  # Optional: Licensing
  # license_type = "Windows_Server"  # Uncomment for Azure Hybrid Benefit
}

# =============================================================================
# Outputs: Display VM Information
# =============================================================================

output "vm_id" {
  value       = module.windows_vm.vm_id
  description = "The ID of the Windows VM"
}

output "vm_name" {
  value       = module.windows_vm.vm_name
  description = "The name of the Windows VM"
}

output "private_ip_address" {
  value       = module.windows_vm.private_ip_address
  description = "The private IP address of the VM"
}

output "identity_principal_id" {
  value       = module.windows_vm.identity_principal_id
  description = "The Principal ID of the managed identity"
}

# Note: Sensitive outputs (admin credentials) are not displayed
# Access them via: terraform output -json | jq '.admin_password.value'
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.4)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (3.117.1)

- <a name="provider_random"></a> [random](#provider\_random) (3.7.2)

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: ../terraform-terraform-namer

Version:

## Resources

The following resources are used by this module:

- [azurerm_managed_disk.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) (resource)
- [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_virtual_machine_data_disk_attachment.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) (resource)
- [azurerm_virtual_machine_extension.antimalware](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.bginfo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.dependency_agent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) (resource)
- [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username)

Description: The admin username for the Windows VM

Type: `string`

### <a name="input_boot_diagnostics_storage_account_uri"></a> [boot\_diagnostics\_storage\_account\_uri](#input\_boot\_diagnostics\_storage\_account\_uri)

Description: The URI of the storage account for boot diagnostics

Type: `string`

### <a name="input_contact"></a> [contact](#input\_contact)

Description: Contact email for resource ownership and notifications

Type: `string`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: Environment name (dev, stg, prd, etc.)

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where resources will be deployed

Type: `string`

### <a name="input_repository"></a> [repository](#input\_repository)

Description: Source repository name for tracking and documentation

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Windows VM

Type: `string`

### <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id)

Description: The ID of the subnet where the network interface will be attached

Type: `string`

### <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size)

Description: The size of the virtual machine (e.g., Standard\_D2s\_v3, Standard\_B2ms)

Type: `string`

### <a name="input_workload"></a> [workload](#input\_workload)

Description: Workload or application name for resource identification

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password)

Description: The admin password for the Windows VM. If not provided, a random password will be generated

Type: `string`

Default: `null`

### <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id)

Description: The ID of the availability set. Mutually exclusive with availability\_zone

Type: `string`

Default: `null`

### <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone)

Description: The availability zone for the VM (e.g., '1', '2', '3'). Mutually exclusive with availability\_set\_id

Type: `string`

Default: `null`

### <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks)

Description: List of data disks to attach to the VM

Type:

```hcl
list(object({
    disk_size_gb         = number
    lun                  = number
    caching              = string
    storage_account_type = string
  }))
```

Default: `[]`

### <a name="input_enable_antimalware"></a> [enable\_antimalware](#input\_enable\_antimalware)

Description: Enable Microsoft Antimalware extension

Type: `bool`

Default: `true`

### <a name="input_enable_azure_monitor_agent"></a> [enable\_azure\_monitor\_agent](#input\_enable\_azure\_monitor\_agent)

Description: Enable Azure Monitor Agent extension

Type: `bool`

Default: `true`

### <a name="input_enable_bginfo"></a> [enable\_bginfo](#input\_enable\_bginfo)

Description: Enable BGInfo extension

Type: `bool`

Default: `true`

### <a name="input_enable_dependency_agent"></a> [enable\_dependency\_agent](#input\_enable\_dependency\_agent)

Description: Enable Dependency Agent extension (requires Azure Monitor Agent)

Type: `bool`

Default: `false`

### <a name="input_enable_disk_encryption_set"></a> [enable\_disk\_encryption\_set](#input\_enable\_disk\_encryption\_set)

Description: Enable disk encryption set for the OS disk

Type: `bool`

Default: `false`

### <a name="input_enable_managed_identity"></a> [enable\_managed\_identity](#input\_enable\_managed\_identity)

Description: Enable system-assigned managed identity for the VM

Type: `bool`

Default: `true`

### <a name="input_enable_secure_boot"></a> [enable\_secure\_boot](#input\_enable\_secure\_boot)

Description: Enable Secure Boot for Generation 2 VMs

Type: `bool`

Default: `true`

### <a name="input_enable_vtpm"></a> [enable\_vtpm](#input\_enable\_vtpm)

Description: Enable vTPM for Generation 2 VMs

Type: `bool`

Default: `true`

### <a name="input_license_type"></a> [license\_type](#input\_license\_type)

Description: The license type for Azure Hybrid Benefit (Windows\_Server or Windows\_Client)

Type: `string`

Default: `null`

### <a name="input_os_disk_caching"></a> [os\_disk\_caching](#input\_os\_disk\_caching)

Description: The caching type for the OS disk

Type: `string`

Default: `"ReadWrite"`

### <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb)

Description: The size of the OS disk in GB. If not specified, uses image default

Type: `number`

Default: `null`

### <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type)

Description: The storage account type for the OS disk

Type: `string`

Default: `"Premium_LRS"`

### <a name="input_os_image_offer"></a> [os\_image\_offer](#input\_os\_image\_offer)

Description: The offer of the OS image

Type: `string`

Default: `"WindowsServer"`

### <a name="input_os_image_publisher"></a> [os\_image\_publisher](#input\_os\_image\_publisher)

Description: The publisher of the OS image

Type: `string`

Default: `"MicrosoftWindowsServer"`

### <a name="input_os_image_sku"></a> [os\_image\_sku](#input\_os\_image\_sku)

Description: The SKU of the OS image (e.g., 2022-datacenter-g2, 2019-datacenter-gensecond)

Type: `string`

Default: `"2022-datacenter-g2"`

### <a name="input_os_image_version"></a> [os\_image\_version](#input\_os\_image\_version)

Description: The version of the OS image

Type: `string`

Default: `"latest"`

### <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode)

Description: The patch assessment mode (AutomaticByPlatform or ImageDefault)

Type: `string`

Default: `"AutomaticByPlatform"`

### <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode)

Description: The patch mode for the VM (AutomaticByOS, AutomaticByPlatform, Manual)

Type: `string`

Default: `"AutomaticByPlatform"`

### <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address)

Description: The static private IP address for the VM. If not provided, dynamic allocation is used

Type: `string`

Default: `null`

### <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id)

Description: The ID of the public IP address to associate with the VM. Leave null for no public IP (recommended)

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password)

Description: The admin password for the VM (auto-generated if not provided)

### <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username)

Description: The admin username for the VM

### <a name="output_antimalware_extension_id"></a> [antimalware\_extension\_id](#output\_antimalware\_extension\_id)

Description: The ID of the Antimalware extension

### <a name="output_availability_set_id"></a> [availability\_set\_id](#output\_availability\_set\_id)

Description: The availability set ID of the VM

### <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone)

Description: The availability zone of the VM

### <a name="output_azure_monitor_agent_id"></a> [azure\_monitor\_agent\_id](#output\_azure\_monitor\_agent\_id)

Description: The ID of the Azure Monitor Agent extension

### <a name="output_computer_name"></a> [computer\_name](#output\_computer\_name)

Description: The computer name of the Windows Virtual Machine

### <a name="output_data_disk_ids"></a> [data\_disk\_ids](#output\_data\_disk\_ids)

Description: The IDs of all data disks

### <a name="output_dependency_agent_id"></a> [dependency\_agent\_id](#output\_dependency\_agent\_id)

Description: The ID of the Dependency Agent extension

### <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id)

Description: The Principal ID of the system-assigned managed identity

### <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id)

Description: The Tenant ID of the system-assigned managed identity

### <a name="output_location"></a> [location](#output\_location)

Description: The Azure region where the VM is deployed

### <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id)

Description: The ID of the network interface

### <a name="output_os_disk_id"></a> [os\_disk\_id](#output\_os\_disk\_id)

Description: The OS disk name

### <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address)

Description: The private IP address of the VM

### <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses)

Description: All private IP addresses of the network interface

### <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name)

Description: The resource group name

### <a name="output_tags"></a> [tags](#output\_tags)

Description: The tags applied to the VM

### <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id)

Description: The ID of the Windows Virtual Machine

### <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name)

Description: The name of the Windows Virtual Machine

### <a name="output_vm_size"></a> [vm\_size](#output\_vm\_size)

Description: The size of the Windows Virtual Machine
<!-- END_TF_DOCS -->

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow and contribution guidelines.

## License

Copyright (c) 2024. All rights reserved.
