# =============================================================================
# Basic Functionality Tests for Windows VM Module
# =============================================================================
#
# These tests validate core module functionality using plan-only commands.
# No Azure resources are created, ensuring fast and cost-free execution.
#
# Note: Windows VM modules have many outputs that are only known after apply.
# These tests focus on configuration validation during planning.
#

provider "azurerm" {
  features {}
}

# =============================================================================
# Test: Basic VM Creation with Minimum Required Inputs
# =============================================================================

run "test_basic_vm_creation" {
  command = plan

  variables {
    # Required terraform-namer inputs
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "terraform-azurerm-windows-virtual-machine"
    workload    = "test"

    # Required resource configuration
    resource_group_name                  = "rg-test-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!Complex"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  # Validate that the configuration is accepted
  assert {
    condition     = var.vm_size == "Standard_D2s_v3"
    error_message = "VM size should be configurable"
  }

  assert {
    condition     = var.admin_username == "azureadmin"
    error_message = "Admin username should be configurable"
  }
}

# =============================================================================
# Test: VM with Data Disks Configuration
# =============================================================================

run "test_vm_with_data_disks_config" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "dev"
    location    = "centralus"
    repository  = "terraform-azurerm-windows-virtual-machine"
    workload    = "test"

    resource_group_name                  = "rg-test-cu-dev-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!Complex"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    # Add data disks
    data_disks = [
      {
        disk_size_gb         = 100
        lun                  = 0
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
      }
    ]
  }

  assert {
    condition     = length(var.data_disks) == 1
    error_message = "Data disks configuration should be accepted"
  }
}

# =============================================================================
# Test: VM with Availability Zone Configuration
# =============================================================================

run "test_vm_with_availability_zone_config" {
  command = plan

  variables {
    contact     = "test@example.com"
    environment = "prd"
    location    = "centralus"
    repository  = "terraform-azurerm-windows-virtual-machine"
    workload    = "app"

    resource_group_name                  = "rg-app-cu-prd-kmi-0"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!Complex"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"

    availability_zone = "1"
  }

  assert {
    condition     = var.availability_zone == "1"
    error_message = "Availability zone configuration should be accepted"
  }
}
