# =============================================================================
# Required Variables - Resource Group and Location
# =============================================================================

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Windows VM"

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty"
  }
}

# =============================================================================
# Required Variables - Network Configuration
# =============================================================================

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the network interface will be attached"

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", var.subnet_id))
    error_message = "Subnet ID must be a valid Azure subnet resource ID"
  }
}

# =============================================================================
# Required Variables - VM Configuration
# =============================================================================

variable "vm_size" {
  type        = string
  description = "The size of the virtual machine (e.g., Standard_D2s_v3, Standard_B2ms)"

  validation {
    condition     = length(var.vm_size) > 0
    error_message = "VM size cannot be empty"
  }
}

variable "admin_username" {
  type        = string
  description = "The admin username for the Windows VM"

  validation {
    condition     = length(var.admin_username) >= 1 && length(var.admin_username) <= 20
    error_message = "Admin username must be 1-20 characters"
  }

  validation {
    condition     = !contains(["administrator", "admin", "user", "user1", "test", "user2", "test1", "user3", "admin1", "1", "123", "a", "actuser", "adm", "admin2", "aspnet", "backup", "console", "david", "guest", "john", "owner", "root", "server", "sql", "support", "support_388945a0", "sys", "test2", "test3", "user4", "user5"], lower(var.admin_username))
    error_message = "Admin username cannot be a reserved name"
  }
}

variable "admin_password" {
  type        = string
  description = "The admin password for the Windows VM. If not provided, a random password will be generated"
  default     = null
  sensitive   = true

  validation {
    condition     = var.admin_password == null || (length(var.admin_password) >= 12 && length(var.admin_password) <= 123)
    error_message = "Admin password must be 12-123 characters if provided"
  }
}

# =============================================================================
# Required Variables - Boot Diagnostics
# =============================================================================

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  description = "The URI of the storage account for boot diagnostics"

  validation {
    condition     = can(regex("^https://.*\\.blob\\.core\\.windows\\.net/$", var.boot_diagnostics_storage_account_uri))
    error_message = "Boot diagnostics storage account URI must be a valid Azure blob storage URI"
  }
}

# =============================================================================
# Optional Variables - Network Configuration
# =============================================================================

variable "private_ip_address" {
  type        = string
  description = "The static private IP address for the VM. If not provided, dynamic allocation is used"
  default     = null
}

variable "public_ip_address_id" {
  type        = string
  description = "The ID of the public IP address to associate with the VM. Leave null for no public IP (recommended)"
  default     = null
}

# =============================================================================
# Optional Variables - OS Image Configuration
# =============================================================================

variable "os_image_publisher" {
  type        = string
  description = "The publisher of the OS image"
  default     = "MicrosoftWindowsServer"
}

variable "os_image_offer" {
  type        = string
  description = "The offer of the OS image"
  default     = "WindowsServer"
}

variable "os_image_sku" {
  type        = string
  description = "The SKU of the OS image (e.g., 2022-datacenter-g2, 2019-datacenter-gensecond)"
  default     = "2022-datacenter-g2"

  validation {
    condition     = contains(["2022-datacenter-g2", "2022-datacenter-azure-edition", "2019-datacenter-gensecond", "2019-datacenter", "2022-datacenter"], var.os_image_sku)
    error_message = "OS image SKU must be a supported Windows Server version"
  }
}

variable "os_image_version" {
  type        = string
  description = "The version of the OS image"
  default     = "latest"
}

# =============================================================================
# Optional Variables - OS Disk Configuration
# =============================================================================

variable "os_disk_caching" {
  type        = string
  description = "The caching type for the OS disk"
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be None, ReadOnly, or ReadWrite"
  }
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "The storage account type for the OS disk"
  default     = "Premium_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.os_disk_storage_account_type)
    error_message = "OS disk storage account type must be a valid Azure managed disk type"
  }
}

variable "os_disk_size_gb" {
  type        = number
  description = "The size of the OS disk in GB. If not specified, uses image default"
  default     = null

  validation {
    condition     = var.os_disk_size_gb == null || (var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 4095)
    error_message = "OS disk size must be between 30 and 4095 GB"
  }
}

variable "disk_encryption_set_id" {
  type        = string
  description = "ID of the Disk Encryption Set for customer-managed key (CMK) encryption. Enables encryption with customer-managed keys stored in Azure Key Vault. Required for HIPAA, PCI-DSS Level 1, and FedRAMP compliance"
  default     = null
}

# =============================================================================
# Optional Variables - Data Disks
# =============================================================================

variable "data_disks" {
  type = list(object({
    disk_size_gb         = number
    lun                  = number
    caching              = string
    storage_account_type = string
  }))
  description = "List of data disks to attach to the VM"
  default     = []

  validation {
    condition     = alltrue([for disk in var.data_disks : disk.disk_size_gb >= 1 && disk.disk_size_gb <= 32767])
    error_message = "Data disk size must be between 1 and 32767 GB"
  }

  validation {
    condition     = alltrue([for disk in var.data_disks : contains(["None", "ReadOnly", "ReadWrite"], disk.caching)])
    error_message = "Data disk caching must be None, ReadOnly, or ReadWrite"
  }

  validation {
    condition     = alltrue([for disk in var.data_disks : contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "UltraSSD_LRS", "StandardSSD_ZRS", "Premium_ZRS"], disk.storage_account_type)])
    error_message = "Data disk storage account type must be valid"
  }
}

# =============================================================================
# Optional Variables - Availability Configuration
# =============================================================================

variable "availability_zone" {
  type        = string
  description = "The availability zone for the VM (e.g., '1', '2', '3'). Mutually exclusive with availability_set_id"
  default     = null

  validation {
    condition     = var.availability_zone == null || contains(["1", "2", "3"], var.availability_zone)
    error_message = "Availability zone must be '1', '2', or '3'"
  }
}

variable "availability_set_id" {
  type        = string
  description = "The ID of the availability set. Mutually exclusive with availability_zone"
  default     = null
}

# =============================================================================
# Optional Variables - Security Configuration
# =============================================================================

variable "enable_secure_boot" {
  type        = bool
  description = "Enable Secure Boot for Generation 2 VMs"
  default     = true
}

variable "enable_vtpm" {
  type        = bool
  description = "Enable vTPM for Generation 2 VMs"
  default     = true
}

variable "enable_managed_identity" {
  type        = bool
  description = "Enable system-assigned managed identity for the VM"
  default     = true
}

# =============================================================================
# Optional Variables - Licensing and Patching
# =============================================================================

variable "license_type" {
  type        = string
  description = "The license type for Azure Hybrid Benefit (Windows_Server or Windows_Client)"
  default     = null

  validation {
    condition     = var.license_type == null || contains(["Windows_Server", "Windows_Client"], var.license_type)
    error_message = "License type must be Windows_Server or Windows_Client"
  }
}

variable "patch_mode" {
  type        = string
  description = "The patch mode for the VM (AutomaticByOS, AutomaticByPlatform, Manual)"
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["AutomaticByOS", "AutomaticByPlatform", "Manual"], var.patch_mode)
    error_message = "Patch mode must be AutomaticByOS, AutomaticByPlatform, or Manual"
  }
}

variable "patch_assessment_mode" {
  type        = string
  description = "The patch assessment mode (AutomaticByPlatform or ImageDefault)"
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patch_assessment_mode)
    error_message = "Patch assessment mode must be AutomaticByPlatform or ImageDefault"
  }
}

# =============================================================================
# Optional Variables - Encryption Configuration
# =============================================================================

variable "enable_encryption_at_host" {
  type        = bool
  description = "Enable encryption at host for double encryption (encryption at both the VM host/hypervisor level AND server-side encryption). Requires VM size support and subscription feature registration. Provides defense-in-depth against VM escape vulnerabilities. Required for Azure Confidential Computing"
  default     = false
}

# =============================================================================
# Optional Variables - VM Extensions
# =============================================================================

variable "enable_azure_monitor_agent" {
  type        = bool
  description = "Enable Azure Monitor Agent extension"
  default     = true
}

variable "enable_dependency_agent" {
  type        = bool
  description = "Enable Dependency Agent extension (requires Azure Monitor Agent)"
  default     = false
}

variable "enable_antimalware" {
  type        = bool
  description = "Enable Microsoft Antimalware extension"
  default     = true
}

variable "enable_bginfo" {
  type        = bool
  description = "Enable BGInfo extension"
  default     = true
}

# =============================================================================
# Naming Variables (terraform-namer)
# =============================================================================

variable "contact" {
  type        = string
  description = "Contact email for resource ownership and notifications"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.contact))
    error_message = "Contact must be a valid email address"
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd, etc.)"

  validation {
    condition     = contains(["ctx", "dev", "stg", "prd", "sbx", "tst", "ops", "hub"], var.environment)
    error_message = "Environment must be one of: ctx, dev, stg, prd, sbx, tst, ops, hub"
  }
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"

  validation {
    condition = contains([
      "centralus", "eastus", "eastus2", "westus", "westus2", "westus3",
      "northcentralus", "southcentralus", "westcentralus",
      "canadacentral", "canadaeast",
      "brazilsouth",
      "northeurope", "westeurope",
      "uksouth", "ukwest",
      "francecentral", "francesouth",
      "germanywestcentral",
      "switzerlandnorth",
      "norwayeast",
      "eastasia", "southeastasia",
      "japaneast", "japanwest",
      "australiaeast", "australiasoutheast",
      "centralindia", "southindia", "westindia"
    ], var.location)
    error_message = "Location must be a valid Azure region"
  }
}

variable "repository" {
  type        = string
  description = "Source repository name for tracking and documentation"

  validation {
    condition     = length(var.repository) > 0
    error_message = "Repository name cannot be empty"
  }
}

variable "workload" {
  type        = string
  description = "Workload or application name for resource identification"

  validation {
    condition     = length(var.workload) > 0 && length(var.workload) <= 20
    error_message = "Workload name must be 1-20 characters"
  }
}
