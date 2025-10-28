# =============================================================================
# Example: Cost-Optimized Windows VM for Dev/Test
# =============================================================================
#
# This configuration demonstrates maximum cost savings for development and
# testing environments. Estimated cost: ~$39/month (72% savings vs default).
#
# Cost Optimizations Applied:
# 1. B-series burstable VM (37% savings on compute)
# 2. StandardSSD disks instead of Premium (55% savings on storage)
# 3. No data disks (only OS disk)
# 4. Auto-shutdown enabled (50% savings - 12 hours/day)
# 5. Monitoring disabled (saves $2.50-12.50/month)
# 6. Smaller OS disk (64 GB instead of 128 GB)
#
# Monthly Cost Breakdown:
# - VM Compute (Standard_B2ms, 12h/day): ~$30/month
# - OS Disk (StandardSSD_LRS 64GB):      ~$5/month
# - Boot Diagnostics:                    ~$0.02/month
# - Antimalware Extension:               $0 (included)
# - Total:                               ~$35-39/month
#
# Compare to default configuration:      ~$138/month
# Savings:                               ~$101/month (-72%)
#

module "windows_vm_dev" {
  source = "../.."

  # ============================================================================
  # Required: Naming Variables
  # ============================================================================
  contact     = "devteam@example.com"
  environment = "dev"
  location    = "centralus"
  repository  = "terraform-azurerm-windows-virtual-machine"
  workload    = "devtest"

  # ============================================================================
  # Required: Resource Configuration
  # ============================================================================
  resource_group_name = "rg-devtest-cu-dev-kmi-0"
  subnet_id           = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-dev/subnets/subnet-dev"

  # ============================================================================
  # Cost Optimization #1: B-series Burstable VM (37% savings)
  # ============================================================================
  vm_size = "Standard_B2ms" # 2 vCPU, 8 GB RAM, burstable to 200% CPU

  # Standard_B2ms:  $60.74/month (24/7) vs Standard_D2s_v3: $96.36/month
  # With auto-shutdown (12h/day): ~$30/month

  # ============================================================================
  # Required: Admin Credentials
  # ============================================================================
  admin_username = "devadmin"
  # Note: In production, use Azure Key Vault for password storage
  admin_password = "DevP@ssw0rd2024!Temp"

  # ============================================================================
  # Required: Boot Diagnostics
  # ============================================================================
  boot_diagnostics_storage_account_uri = "https://stdiagdev.blob.core.windows.net/"

  # ============================================================================
  # Cost Optimization #2: StandardSSD Disks (55% savings vs Premium)
  # ============================================================================
  os_disk_storage_account_type = "StandardSSD_LRS" # $5.12/month for 64GB
  os_disk_size_gb              = 64                # Minimum recommended size

  # Premium_LRS (128GB): $19.71/month
  # StandardSSD_LRS (64GB): $5.12/month
  # Savings: $14.59/month (-74%)

  # ============================================================================
  # Cost Optimization #3: No Data Disks (saves ~$19.71/month)
  # ============================================================================
  data_disks = []

  # For dev/test, use OS disk only. Add data disks only if required.

  # ============================================================================
  # Cost Optimization #4: Disable Monitoring (saves $2.50-12.50/month)
  # ============================================================================
  enable_azure_monitor_agent = false # No Log Analytics ingestion costs
  enable_dependency_agent    = false # Not needed for dev/test

  # Azure Monitor Agent ingests logs to Log Analytics:
  # - First 5 GB/month: Free
  # - Additional data: $2.50/GB
  # Dev VMs typically generate 1-5 GB/month

  # ============================================================================
  # Security: Keep Essential Extensions Enabled
  # ============================================================================
  enable_antimalware = true  # No additional cost, important for security
  enable_bginfo      = false # Not needed for dev/test

  # ============================================================================
  # Security: Enable for Gen2 VMs (no additional cost)
  # ============================================================================
  enable_secure_boot = true
  enable_vtpm        = true

  # ============================================================================
  # Cost Optimization #5: Auto-Shutdown (50% savings)
  # ============================================================================
  # enable_auto_shutdown = true          # Proposed feature
  # auto_shutdown_time   = "1900"        # 7:00 PM
  # auto_shutdown_timezone = "Central Standard Time"

  # Dev/test VMs rarely need 24/7 uptime. Auto-shutdown saves 50% on compute.
  # Manually configure in Azure Portal:
  # VM → Operations → Auto-shutdown → Enable → Set time to 7:00 PM

  # ============================================================================
  # Optional: OS Image (Windows Server 2022 Gen2)
  # ============================================================================
  os_image_sku = "2022-datacenter-g2"

  # ============================================================================
  # Optional: Availability (Not needed for dev/test)
  # ============================================================================
  # availability_zone = null  # No zone for cost savings (minimal impact)

  # ============================================================================
  # Optional: Licensing (Not applicable for dev/test)
  # ============================================================================
  # license_type = null  # Pay-as-you-go for flexibility
}

# =============================================================================
# Outputs: Display VM Information
# =============================================================================

output "vm_id" {
  value       = module.windows_vm_dev.vm_id
  description = "The ID of the cost-optimized Windows VM"
}

output "vm_name" {
  value       = module.windows_vm_dev.vm_name
  description = "The name of the cost-optimized Windows VM"
}

output "private_ip_address" {
  value       = module.windows_vm_dev.private_ip_address
  description = "The private IP address of the VM"
}

output "estimated_monthly_cost" {
  value       = "$35-39 USD/month (with auto-shutdown configured manually)"
  description = "Estimated monthly cost in US Central region"
}

# =============================================================================
# Cost Comparison
# =============================================================================

# Default Configuration (examples/default):
# - VM:           Standard_D2s_v3, Premium_LRS disks = $138/month
#
# This Configuration (cost-optimized):
# - VM:           Standard_B2ms, StandardSSD_LRS, auto-shutdown = $35-39/month
#
# Savings:        $99-103/month (-72%)
#
# Additional Optimizations (if applicable):
# - Azure Hybrid Benefit (license_type = "Windows_Server"): -$40-50/month
# - 1-year Reserved Instance: -31% additional savings
# - 3-year Reserved Instance: -51% additional savings
