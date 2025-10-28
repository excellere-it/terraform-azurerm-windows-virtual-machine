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
