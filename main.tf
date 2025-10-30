# =============================================================================
# Module: Azure Windows Virtual Machine
# =============================================================================
#
# Purpose:
#   This module creates and manages Azure Windows Virtual Machines with
#   comprehensive security, monitoring, and operational features.
#
# Features:
#   - Windows Server 2019/2022 Datacenter support
#   - Configurable VM sizes (Standard_B2s to Standard_D32s_v3+)
#   - Network interface with private IP (no public IP by default)
#   - Encrypted managed disks (OS disk + optional data disks)
#   - Secure Boot and vTPM for Generation 2 VMs
#   - Boot diagnostics with storage account
#   - Optional VM extensions (Azure Monitor, Dependency Agent, Antimalware)
#   - Availability zones or availability sets
#   - Backup integration ready
#   - Consistent naming and tagging via terraform-namer
#
# Resources Created:
#   - azurerm_network_interface
#   - azurerm_windows_virtual_machine
#   - azurerm_managed_disk (optional data disks)
#   - azurerm_virtual_machine_data_disk_attachment (optional)
#   - azurerm_virtual_machine_extension (optional monitoring/antimalware)
#
# Dependencies:
#   - terraform-terraform-namer (required)
#   - Existing subnet for network interface
#   - Existing storage account for boot diagnostics
#
# Usage:
#   module "windows_vm" {
#     source = "path/to/terraform-azurerm-windows-virtual-machine"
#
#     contact     = "admin@company.com"
#     environment = "dev"
#     location    = "centralus"
#     repository  = "infrastructure"
#     workload    = "app"
#
#     resource_group_name = "rg-app-cu-dev-kmi-0"
#     subnet_id           = "/subscriptions/.../subnets/subnet-app"
#     vm_size             = "Standard_D2s_v3"
#     admin_username      = "azureadmin"
#     admin_password      = "P@ssw0rd1234!" # Use Azure Key Vault in production
#
#     boot_diagnostics_storage_account_uri = "https://stdiag.blob.core.windows.net/"
#   }
#
# Security Considerations:
#   - Store admin passwords in Azure Key Vault, not in code
#   - Enable Azure Defender for Servers
#   - Configure NSG rules on the subnet
#   - Enable Azure Backup for production VMs
#   - Review and enable VM extensions as needed
#   - Use managed identity instead of stored credentials where possible
#
# =============================================================================

# =============================================================================
# Section: Naming and Tagging
# =============================================================================

module "naming" {
  source  = "app.terraform.io/infoex/namer/terraform"
  version = "0.0.3"

  contact     = var.contact
  environment = var.environment
  location    = var.location
  repository  = var.repository
  workload    = var.workload
}

# =============================================================================
# Section: Random Password Generation (Optional)
# =============================================================================

resource "random_password" "admin_password" {
  count = var.admin_password == null ? 1 : 0

  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}

# =============================================================================
# Section: Network Interface
# =============================================================================

resource "azurerm_network_interface" "this" {
  name                = "nic-${module.naming.resource_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.public_ip_address_id
  }

  tags = module.naming.tags
}

# =============================================================================
# Section: Windows Virtual Machine
# =============================================================================

resource "azurerm_windows_virtual_machine" "this" {
  name                = "vm-${module.naming.resource_suffix_vm}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password != null ? var.admin_password : random_password.admin_password[0].result

  availability_set_id = var.availability_set_id
  zone                = var.availability_zone

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  # OS Disk Configuration
  os_disk {
    name                   = "osdisk-${module.naming.resource_suffix_vm}"
    caching                = var.os_disk_caching
    storage_account_type   = var.os_disk_storage_account_type
    disk_size_gb           = var.os_disk_size_gb
    disk_encryption_set_id = var.disk_encryption_set_id
  }

  # OS Image Configuration
  source_image_reference {
    publisher = var.os_image_publisher
    offer     = var.os_image_offer
    sku       = var.os_image_sku
    version   = var.os_image_version
  }

  # Security Configuration (Generation 2 VMs)
  secure_boot_enabled        = var.enable_secure_boot
  vtpm_enabled               = var.enable_vtpm
  encryption_at_host_enabled = var.enable_encryption_at_host

  # Boot Diagnostics
  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }

  # Identity Configuration
  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  # Licensing
  license_type = var.license_type

  # Patching Configuration
  patch_mode              = var.patch_mode
  patch_assessment_mode   = var.patch_assessment_mode
  enable_automatic_updates = var.enable_automatic_updates

  tags = module.naming.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to admin password to prevent drift
      admin_password,
    ]
  }
}

# =============================================================================
# Section: Data Disks (Optional)
# =============================================================================

resource "azurerm_managed_disk" "data" {
  for_each = { for idx, disk in var.data_disks : idx => disk }

  name                   = "datadisk-${module.naming.resource_suffix_vm}-${each.key}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  storage_account_type   = each.value.storage_account_type
  create_option          = "Empty"
  disk_size_gb           = each.value.disk_size_gb
  disk_encryption_set_id = var.disk_encryption_set_id

  zone = var.availability_zone

  tags = module.naming.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each = { for idx, disk in var.data_disks : idx => disk }

  managed_disk_id    = azurerm_managed_disk.data[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = each.value.lun
  caching            = each.value.caching
}

# =============================================================================
# Section: VM Extensions - Azure Monitor Agent (Optional)
# =============================================================================

resource "azurerm_virtual_machine_extension" "azure_monitor" {
  count = var.enable_azure_monitor_agent ? 1 : 0

  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = module.naming.tags
}

# =============================================================================
# Section: VM Extensions - Dependency Agent (Optional)
# =============================================================================

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count = var.enable_dependency_agent ? 1 : 0

  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true

  tags = module.naming.tags

  depends_on = [
    azurerm_virtual_machine_extension.azure_monitor
  ]
}

# =============================================================================
# Section: VM Extensions - Antimalware (Optional)
# =============================================================================

resource "azurerm_virtual_machine_extension" "antimalware" {
  count = var.enable_antimalware ? 1 : 0

  name                       = "IaaSAntimalware"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    AntimalwareEnabled        = true
    RealtimeProtectionEnabled = "true"
    ScheduledScanSettings = {
      isEnabled = "true"
      day       = "7"
      time      = "120"
      scanType  = "Quick"
    }
    Exclusions = {
      Extensions = ""
      Paths      = ""
      Processes  = ""
    }
  })

  tags = module.naming.tags
}

# =============================================================================
# Section: VM Extensions - BGInfo (Optional)
# =============================================================================

resource "azurerm_virtual_machine_extension" "bginfo" {
  count = var.enable_bginfo ? 1 : 0

  name                       = "BGInfo"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Compute"
  type                       = "BGInfo"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true

  tags = module.naming.tags
}
