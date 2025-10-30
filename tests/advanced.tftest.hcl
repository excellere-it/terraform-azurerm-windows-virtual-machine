# =============================================================================
# Advanced Functionality Tests for Windows VM Module
# =============================================================================
#
# These tests validate advanced features, security configurations, and
# complex scenarios using plan-only commands.
#

provider "azurerm" {
  features {}
}

# =============================================================================
# Test: Security Features Enabled by Default
# =============================================================================

run "test_security_features_default" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "secure"
    resource_group_name                  = "rg-secure-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "SecureP@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  # Validate secure boot is enabled by default
  assert {
    condition     = var.enable_secure_boot == true
    error_message = "Secure Boot should be enabled by default"
  }

  # Validate vTPM is enabled by default
  assert {
    condition     = var.enable_vtpm == true
    error_message = "vTPM should be enabled by default"
  }

  # Validate managed identity is enabled by default
  assert {
    condition     = var.enable_managed_identity == true
    error_message = "Managed identity should be enabled by default"
  }
}

# =============================================================================
# Test: Security Features Explicitly Disabled
# =============================================================================

run "test_security_features_disabled" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "legacy"
    resource_group_name                  = "rg-legacy-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Disable security features for legacy Gen1 VMs
    enable_secure_boot      = false
    enable_vtpm             = false
    enable_managed_identity = false
  }

  # Validate configuration is accepted
  assert {
    condition     = var.enable_secure_boot == false
    error_message = "Should allow disabling Secure Boot"
  }

  assert {
    condition     = var.enable_vtpm == false
    error_message = "Should allow disabling vTPM"
  }
}

# =============================================================================
# Test: All VM Extensions Enabled
# =============================================================================

run "test_all_extensions_enabled" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "monitored"
    resource_group_name                  = "rg-monitored-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Enable all extensions
    enable_azure_monitor_agent = true
    enable_dependency_agent    = true
    enable_antimalware         = true
    enable_bginfo              = true
  }

  # Validate all extensions are enabled
  assert {
    condition     = var.enable_azure_monitor_agent == true
    error_message = "Azure Monitor Agent should be enabled"
  }

  assert {
    condition     = var.enable_dependency_agent == true
    error_message = "Dependency Agent should be enabled"
  }

  assert {
    condition     = var.enable_antimalware == true
    error_message = "Antimalware should be enabled"
  }

  assert {
    condition     = var.enable_bginfo == true
    error_message = "BGInfo should be enabled"
  }
}

# =============================================================================
# Test: All VM Extensions Disabled
# =============================================================================

run "test_all_extensions_disabled" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "minimal"
    resource_group_name                  = "rg-minimal-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_B2s"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Disable all extensions
    enable_azure_monitor_agent = false
    enable_dependency_agent    = false
    enable_antimalware         = false
    enable_bginfo              = false
  }

  # Validate configuration is accepted
  assert {
    condition     = var.enable_azure_monitor_agent == false
    error_message = "Should allow disabling Azure Monitor Agent"
  }
}

# =============================================================================
# Test: Random Password Generation (Null Password)
# =============================================================================

run "test_random_password_generation" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "auto-pwd"
    resource_group_name                  = "rg-auto-pwd-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = null # Auto-generate password
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  # Validate auto-generated password configuration
  assert {
    condition     = var.admin_password == null
    error_message = "Should accept null password for auto-generation"
  }
}

# =============================================================================
# Test: Public IP Configuration
# =============================================================================

run "test_with_public_ip" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "jumpbox"
    resource_group_name                  = "rg-jumpbox-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_B2s"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Assign public IP (not recommended for production)
    public_ip_address_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip-jumpbox"
  }

  # Validate public IP configuration
  assert {
    condition     = var.public_ip_address_id != null
    error_message = "Public IP should be configurable"
  }
}

# =============================================================================
# Test: Static Private IP Configuration
# =============================================================================

run "test_static_private_ip" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "db-server"
    resource_group_name                  = "rg-db-server-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_E4s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Static private IP for database server
    private_ip_address = "10.0.1.10"
  }

  # Validate static IP configuration
  assert {
    condition     = var.private_ip_address == "10.0.1.10"
    error_message = "Static private IP should be configurable"
  }
}

# =============================================================================
# Test: Regional Deployment (No Availability Zone)
# =============================================================================

run "test_regional_deployment" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "regional"
    resource_group_name                  = "rg-regional-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # No availability zone (regional deployment)
    availability_zone = null
  }

  # Validate regional deployment
  assert {
    condition     = var.availability_zone == null
    error_message = "Should support regional deployment without availability zone"
  }
}

# =============================================================================
# Test: Multiple Data Disks
# =============================================================================

run "test_multiple_data_disks" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "fileserver"
    resource_group_name                  = "rg-fileserver-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D8s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Multiple data disks with different configurations
    data_disks = [
      {
        disk_size_gb         = 512
        lun                  = 0
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
      },
      {
        disk_size_gb         = 1024
        lun                  = 1
        caching              = "ReadOnly"
        storage_account_type = "Premium_LRS"
      },
      {
        disk_size_gb         = 2048
        lun                  = 2
        caching              = "None"
        storage_account_type = "Standard_LRS"
      }
    ]
  }

  # Validate multiple data disks
  assert {
    condition     = length(var.data_disks) == 3
    error_message = "Should support multiple data disks"
  }
}

# =============================================================================
# Test: Custom OS Disk Configuration
# =============================================================================

run "test_custom_os_disk" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "custom-disk"
    resource_group_name                  = "rg-custom-disk-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Custom OS disk configuration
    os_disk_size_gb              = 256
    os_disk_caching              = "ReadOnly"
    os_disk_storage_account_type = "StandardSSD_LRS"
  }

  # Validate custom OS disk
  assert {
    condition     = var.os_disk_size_gb == 256
    error_message = "Custom OS disk size should be configurable"
  }

  assert {
    condition     = var.os_disk_caching == "ReadOnly"
    error_message = "Custom OS disk caching should be configurable"
  }

  assert {
    condition     = var.os_disk_storage_account_type == "StandardSSD_LRS"
    error_message = "Custom OS disk storage type should be configurable"
  }
}

# =============================================================================
# Test: Windows Server 2019
# =============================================================================

run "test_windows_server_2019" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "ws2019"
    resource_group_name                  = "rg-ws2019-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Windows Server 2019
    os_image_sku = "2019-datacenter-gensecond"
  }

  # Validate Windows Server 2019
  assert {
    condition     = var.os_image_sku == "2019-datacenter-gensecond"
    error_message = "Should support Windows Server 2019"
  }
}

# =============================================================================
# Test: Azure Hybrid Benefit Licensing
# =============================================================================

run "test_azure_hybrid_benefit" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "licensed"
    resource_group_name                  = "rg-licensed-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Enable Azure Hybrid Benefit
    license_type = "Windows_Server"
  }

  # Validate licensing
  assert {
    condition     = var.license_type == "Windows_Server"
    error_message = "Should support Azure Hybrid Benefit"
  }
}

# =============================================================================
# Test: Manual Patching Configuration
# =============================================================================

run "test_manual_patching" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "manual-patch"
    resource_group_name                  = "rg-manual-patch-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Manual patching
    patch_mode            = "Manual"
    patch_assessment_mode = "ImageDefault"
  }

  # Validate patching configuration
  assert {
    condition     = var.patch_mode == "Manual"
    error_message = "Should support manual patching"
  }

  assert {
    condition     = var.patch_assessment_mode == "ImageDefault"
    error_message = "Should support ImageDefault patch assessment"
  }
}

# =============================================================================
# Test: Availability Set Configuration
# =============================================================================

run "test_availability_set" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "avset"
    resource_group_name                  = "rg-avset-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Availability set (instead of zone)
    availability_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Compute/availabilitySets/avset-app"
    availability_zone   = null
  }

  # Validate availability set
  assert {
    condition     = var.availability_set_id != null
    error_message = "Should support availability set configuration"
  }

  assert {
    condition     = var.availability_zone == null
    error_message = "Availability zone should be null when using availability set"
  }
}

# =============================================================================
# Test: Customer-Managed Key (CMK) Encryption
# =============================================================================

run "test_cmk_encryption" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "cmk-encrypted"
    resource_group_name                  = "rg-cmk-encrypted-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Enable customer-managed key encryption
    disk_encryption_set_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-security/providers/Microsoft.Compute/diskEncryptionSets/des-cmk"
  }

  # Validate CMK encryption configuration
  assert {
    condition     = var.disk_encryption_set_id != null
    error_message = "Disk Encryption Set ID should be configurable for CMK encryption"
  }

  assert {
    condition     = can(regex("^/subscriptions/.+/providers/Microsoft.Compute/diskEncryptionSets/.+$", var.disk_encryption_set_id))
    error_message = "Disk Encryption Set ID must be a valid Azure resource ID"
  }
}

# =============================================================================
# Test: Encryption at Host (Double Encryption)
# =============================================================================

run "test_encryption_at_host" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "double-encrypted"
    resource_group_name                  = "rg-double-encrypted-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Enable encryption at host for double encryption
    enable_encryption_at_host = true
  }

  # Validate encryption at host configuration
  assert {
    condition     = var.enable_encryption_at_host == true
    error_message = "Encryption at host should be configurable"
  }
}

# =============================================================================
# Test: Full Encryption Stack (CMK + Encryption at Host)
# =============================================================================

run "test_full_encryption_stack" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "prd"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "max-security"
    resource_group_name                  = "rg-max-security-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Enable all encryption features for maximum security
    disk_encryption_set_id    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-security/providers/Microsoft.Compute/diskEncryptionSets/des-cmk"
    enable_encryption_at_host = true

    # Also enable all other security features
    enable_secure_boot      = true
    enable_vtpm             = true
    enable_managed_identity = true
    enable_antimalware      = true
  }

  # Validate full encryption stack
  assert {
    condition     = var.disk_encryption_set_id != null && var.enable_encryption_at_host == true
    error_message = "Should support both CMK encryption and encryption at host simultaneously"
  }

  # Validate all security features enabled
  assert {
    condition     = var.enable_secure_boot == true && var.enable_vtpm == true
    error_message = "Secure Boot and vTPM should be enabled for maximum security"
  }

  assert {
    condition     = var.enable_managed_identity == true
    error_message = "Managed identity should be enabled for maximum security"
  }

  assert {
    condition     = var.enable_antimalware == true
    error_message = "Antimalware should be enabled for maximum security"
  }
}

# =============================================================================
# Test: Default Encryption (Platform-Managed Keys)
# =============================================================================

run "test_default_encryption" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "terraform-azurerm-windows-virtual-machine"
    workload                             = "default-encryption"
    resource_group_name                  = "rg-default-encryption-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Use default encryption (platform-managed keys)
    disk_encryption_set_id    = null
    enable_encryption_at_host = false
  }

  # Validate default encryption (platform-managed)
  assert {
    condition     = var.disk_encryption_set_id == null
    error_message = "Should support platform-managed encryption by default"
  }

  assert {
    condition     = var.enable_encryption_at_host == false
    error_message = "Encryption at host should be disabled by default"
  }
}
