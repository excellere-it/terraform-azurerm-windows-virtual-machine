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

# =============================================================================
# Test: Invalid Subnet ID Format
# =============================================================================

run "test_invalid_subnet_id_format" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "invalid-subnet-id"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.subnet_id,
  ]
}

# =============================================================================
# Test: Invalid Boot Diagnostics URI Format
# =============================================================================

run "test_invalid_boot_diagnostics_uri" {
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
    boot_diagnostics_storage_account_uri = "http://not-https.example.com/"
  }

  expect_failures = [
    var.boot_diagnostics_storage_account_uri,
  ]
}

# =============================================================================
# Test: Invalid License Type
# =============================================================================

run "test_invalid_license_type" {
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
    license_type                         = "Invalid_License"
  }

  expect_failures = [
    var.license_type,
  ]
}

# =============================================================================
# Test: Invalid OS Disk Caching Mode
# =============================================================================

run "test_invalid_os_disk_caching" {
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
    os_disk_caching                      = "InvalidCaching"
  }

  expect_failures = [
    var.os_disk_caching,
  ]
}

# =============================================================================
# Test: Invalid OS Disk Storage Account Type
# =============================================================================

run "test_invalid_os_disk_storage_type" {
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
    os_disk_storage_account_type         = "Invalid_Storage"
  }

  expect_failures = [
    var.os_disk_storage_account_type,
  ]
}

# =============================================================================
# Test: OS Disk Size Below Minimum
# =============================================================================

run "test_os_disk_size_below_minimum" {
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
    os_disk_size_gb                      = 20 # Below minimum of 30
  }

  expect_failures = [
    var.os_disk_size_gb,
  ]
}

# =============================================================================
# Test: OS Disk Size Above Maximum
# =============================================================================

run "test_os_disk_size_above_maximum" {
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
    os_disk_size_gb                      = 5000 # Above maximum of 4095
  }

  expect_failures = [
    var.os_disk_size_gb,
  ]
}

# =============================================================================
# Test: Invalid Workload Name (Too Long)
# =============================================================================

run "test_invalid_workload_too_long" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = "test-repo"
    workload                             = "this-workload-name-is-way-too-long-and-exceeds-twenty-characters"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.workload,
  ]
}

# =============================================================================
# Test: Invalid Repository (Empty String)
# =============================================================================

run "test_invalid_repository_empty" {
  command = plan

  variables {
    contact                              = "test@example.com"
    environment                          = "dev"
    location                             = "centralus"
    repository                           = ""
    workload                             = "test"
    resource_group_name                  = "rg-test"
    subnet_id                            = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
    vm_size                              = "Standard_D2s_v3"
    admin_username                       = "azureadmin"
    admin_password                       = "P@ssw0rd1234!"
    boot_diagnostics_storage_account_uri = "https://stdiagtest.blob.core.windows.net/"
  }

  expect_failures = [
    var.repository,
  ]
}

# =============================================================================
# Test: Data Disk Size Below Minimum
# =============================================================================

run "test_data_disk_size_below_minimum" {
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
    data_disks = [
      {
        disk_size_gb         = 0 # Below minimum of 1
        lun                  = 0
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
      }
    ]
  }

  expect_failures = [
    var.data_disks,
  ]
}

# =============================================================================
# Test: Data Disk Invalid Caching Mode
# =============================================================================

run "test_data_disk_invalid_caching" {
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
    data_disks = [
      {
        disk_size_gb         = 100
        lun                  = 0
        caching              = "InvalidCaching" # Invalid
        storage_account_type = "Premium_LRS"
      }
    ]
  }

  expect_failures = [
    var.data_disks,
  ]
}

# =============================================================================
# Test: Data Disk Invalid Storage Type
# =============================================================================

run "test_data_disk_invalid_storage_type" {
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
    data_disks = [
      {
        disk_size_gb         = 100
        lun                  = 0
        caching              = "ReadWrite"
        storage_account_type = "Invalid_Storage" # Invalid
      }
    ]
  }

  expect_failures = [
    var.data_disks,
  ]
}
