# =============================================================================
# Input Validation Tests for Windows VM Module
# =============================================================================
#
# These tests validate that input variables are properly constrained and
# that invalid inputs trigger appropriate validation errors.
#

provider "azurerm" {
  features {}
}

# =============================================================================
# Test: Invalid Environment
# =============================================================================

run "test_invalid_environment" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "invalid"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.environment,
  ]
}

# =============================================================================
# Test: Invalid Location
# =============================================================================

run "test_invalid_location" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "invalid-region"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.location,
  ]
}

# =============================================================================
# Test: Invalid Contact Format
# =============================================================================

run "test_invalid_contact_format" {
  command = plan

  variables {
    contact                              = "not-an-email"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.contact,
  ]
}

# =============================================================================
# Test: Invalid Admin Username (Reserved Name)
# =============================================================================

run "test_invalid_admin_username_reserved" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "administrator"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.admin_username,
  ]
}

# =============================================================================
# Test: Invalid Admin Password (Too Short)
# =============================================================================

run "test_invalid_admin_password_too_short" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "Short1!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.admin_password,
  ]
}

# =============================================================================
# Test: Invalid Availability Zone
# =============================================================================

run "test_invalid_availability_zone" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
    availability_zone                    = "5"
  }

  expect_failures = [
    var.availability_zone,
  ]
}

# =============================================================================
# Test: Invalid OS Image SKU
# =============================================================================

run "test_invalid_os_image_sku" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
    os_image_sku                         = "invalid-sku"
  }

  expect_failures = [
    var.os_image_sku,
  ]
}

# =============================================================================
# Test: Invalid Patch Mode
# =============================================================================

run "test_invalid_patch_mode" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
    patch_mode                           = "InvalidMode"
  }

  expect_failures = [
    var.patch_mode,
  ]
}
