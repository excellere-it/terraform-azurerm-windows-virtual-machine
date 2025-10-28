# =============================================================================
# Example: Production-Grade Windows VM with Cost Optimization
# =============================================================================
#
# This configuration demonstrates production-ready deployment with cost
# optimizations. Estimated cost: ~$60/month (57% savings vs unoptimized).
#
# Cost Optimizations Applied:
# 1. AMD-based D-series VM (24% savings vs Intel)
# 2. Azure Hybrid Benefit enabled (40-50% license savings)
# 3. Premium disks for performance (production requirement)
# 4. Full monitoring and security enabled
# 5. Availability zone for 99.99% SLA
# 6. (Recommended) 1-year Reserved Instance for 31% additional savings
#
# Monthly Cost Breakdown (with optimizations):
# - VM Compute (Standard_D2as_v5, AHB):  ~$40/month
# - OS Disk (Premium_LRS 128GB):         ~$20/month
# - Data Disk (Premium_LRS 256GB):       ~$40/month
# - Boot Diagnostics:                    ~$0.02/month
# - Azure Monitor (5 GB):                ~$0/month (free tier)
# - Total (pay-as-you-go):               ~$100/month
# - Total (1-year RI):                   ~$60/month
#
# Compare to unoptimized production:     ~$140-180/month
# Savings with optimizations:            ~$80/month (-57%)
#

module "windows_vm_prod" {
  source = "../.."

  # ============================================================================
  # Required: Naming Variables
  # ============================================================================
  contact     = "operations@example.com"
  environment = "prd"
  location    = "centralus"
  repository  = "terraform-azurerm-windows-virtual-machine"
  workload    = "app"

  # ============================================================================
  # Required: Resource Configuration
  # ============================================================================
  resource_group_name = "rg-app-cu-prd-kmi-0"
  subnet_id           = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network-prd/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/subnet-app"

  # ============================================================================
  # Cost Optimization #1: AMD-based VM (24% savings vs Intel D2s_v3)
  # ============================================================================
  vm_size = "Standard_D2as_v5" # 2 vCPU, 8 GB RAM, AMD EPYC processor

  # Comparison:
  # - Standard_D2s_v3 (Intel):   $96.36/month
  # - Standard_D2as_v5 (AMD):    $73.73/month
  # Savings: $22.63/month (-24%)
  #
  # With Azure Hybrid Benefit: $73.73 - $45 = ~$28.73/month
  # With 1-year RI: $28.73 × 0.69 = ~$19.82/month
  # With 3-year RI: $28.73 × 0.49 = ~$14.08/month

  # ============================================================================
  # Required: Admin Credentials
  # ============================================================================
  admin_username = "azureadmin"

  # IMPORTANT: Use Azure Key Vault in production
  # Example with Key Vault data source (when feature is available):
  # key_vault_id          = data.azurerm_key_vault.prod.id
  # key_vault_secret_name = "vm-admin-password"

  # Temporary for example:
  admin_password = "ProdP@ssw0rd2024!Secure"

  # ============================================================================
  # Required: Boot Diagnostics
  # ============================================================================
  boot_diagnostics_storage_account_uri = "https://stdiagprod.blob.core.windows.net/"

  # ============================================================================
  # Cost Optimization #2: Azure Hybrid Benefit (40-50% license savings)
  # ============================================================================
  license_type = "Windows_Server"

  # Requires: Active Software Assurance or Windows Server subscription
  # Savings: ~$40-50/month per VM
  #
  # Without AHB: Full Windows Server license cost included in VM price
  # With AHB:    Bring your own license, pay only for compute
  #
  # Eligibility: Must have Windows Server licenses with Software Assurance
  # Learn more: https://azure.microsoft.com/pricing/hybrid-benefit/

  # ============================================================================
  # Storage: Premium Disks for Production Performance
  # ============================================================================
  os_disk_storage_account_type = "Premium_LRS" # P10: 128 GB, 500 IOPS, 100 MB/s
  os_disk_size_gb              = 128

  # Premium_LRS required for:
  # - Production SLA (99.9% single instance with Premium disks)
  # - High IOPS/throughput requirements
  # - Low latency (<10ms)

  # ============================================================================
  # Data Disks: Production Application Data
  # ============================================================================
  data_disks = [
    {
      disk_size_gb         = 256                # P15: 256 GB, 1,100 IOPS, 125 MB/s
      lun                  = 0
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
    }
  ]

  # Cost: P15 (256 GB) = ~$40.96/month
  #
  # Right-size based on workload:
  # - P10 (128 GB, 500 IOPS):      $19.71/month
  # - P15 (256 GB, 1,100 IOPS):    $40.96/month
  # - P20 (512 GB, 2,300 IOPS):    $75.78/month

  # ============================================================================
  # Security: Generation 2 VM Features (no additional cost)
  # ============================================================================
  enable_secure_boot = true # UEFI Secure Boot
  enable_vtpm        = true # Virtual TPM for BitLocker, measured boot

  # ============================================================================
  # Security: Managed Identity (no additional cost)
  # ============================================================================
  enable_managed_identity = true

  # Use managed identity for:
  # - Azure Key Vault access
  # - Azure Storage authentication
  # - Azure SQL Database connections
  # - Eliminates need for stored credentials

  # ============================================================================
  # Monitoring: Azure Monitor Agent (first 5 GB free)
  # ============================================================================
  enable_azure_monitor_agent = true
  enable_dependency_agent    = false # Only if using Service Map/VM Insights

  # Azure Monitor costs:
  # - First 5 GB/month ingestion: Free
  # - Additional data: $2.50/GB
  # - Typical production VM: 2-10 GB/month
  #
  # Optimize costs:
  # 1. Use data collection rules to filter events
  # 2. Set retention to 30-90 days (not 2 years)
  # 3. Use Basic Logs for less critical data (88% cheaper)

  # ============================================================================
  # Security Extensions
  # ============================================================================
  enable_antimalware = true  # Microsoft Antimalware (no additional cost)
  enable_bginfo      = true  # Desktop info display (no additional cost)

  # ============================================================================
  # OS Image: Windows Server 2022 Generation 2
  # ============================================================================
  os_image_sku = "2022-datacenter-g2"

  # Alternative SKUs:
  # - "2022-datacenter-azure-edition":  Azure-optimized features
  # - "2019-datacenter-gensecond":      Windows Server 2019 Gen2

  # ============================================================================
  # Availability: Zone Deployment for 99.99% SLA
  # ============================================================================
  availability_zone = "1"

  # SLA comparison:
  # - No availability option:              99.9% SLA
  # - Single zone (this config):           99.99% SLA
  # - Multiple VMs across zones:           99.99% SLA
  # - Availability Set:                    99.95% SLA
  #
  # Cost: No additional charge for zone deployment

  # ============================================================================
  # Patching: Automatic Updates
  # ============================================================================
  patch_mode            = "AutomaticByPlatform" # Azure-orchestrated patching
  patch_assessment_mode = "AutomaticByPlatform" # Automatic compliance scanning

  # Reduces operational overhead, no additional cost

  # ============================================================================
  # Network Security (if NSG integration added)
  # ============================================================================
  # network_security_group_id = azurerm_network_security_group.app.id
  public_ip_address_id = null # No public IP for security

  # Access production VMs via:
  # - Azure Bastion (secure RDP without public IP)
  # - VPN Gateway
  # - ExpressRoute
}

# =============================================================================
# Outputs: Display VM Information
# =============================================================================

output "vm_id" {
  value       = module.windows_vm_prod.vm_id
  description = "The ID of the production Windows VM"
}

output "vm_name" {
  value       = module.windows_vm_prod.vm_name
  description = "The name of the production Windows VM"
}

output "private_ip_address" {
  value       = module.windows_vm_prod.private_ip_address
  description = "The private IP address of the VM"
}

output "identity_principal_id" {
  value       = module.windows_vm_prod.identity_principal_id
  description = "Managed identity Principal ID for RBAC assignments"
}

output "estimated_monthly_cost" {
  value = <<-EOT
    Estimated monthly cost in US Central region:

    Pay-as-you-go:          ~$100/month
    With 1-year RI:         ~$60/month (-40%)
    With 3-year RI:         ~$45/month (-55%)

    Breakdown (pay-as-you-go with AHB):
    - VM Compute (D2as_v5, AHB):  ~$40/month
    - OS Disk (Premium 128GB):    ~$20/month
    - Data Disk (Premium 256GB):  ~$40/month
    - Monitoring (5 GB):          ~$0/month (free tier)

    Purchase Reserved Instances in Azure Portal for additional savings.
  EOT
  description = "Estimated monthly cost with various commitment options"
}

# =============================================================================
# Cost Optimization Summary
# =============================================================================

# Optimizations Applied:
# 1. AMD-based VM (D2as_v5):              -$22.63/month (-24%)
# 2. Azure Hybrid Benefit:                -$45/month (-40-50%)
# 3. (Recommended) 1-year Reserved:       -31% additional
# 4. Right-sized disks:                   Baseline (performance required)
# 5. Zone deployment:                     $0 (included, improves SLA)
#
# Total Savings (pay-as-you-go optimized vs unoptimized):
# - Unoptimized: $180/month (Intel, no AHB, oversized disks)
# - Optimized:   $100/month
# - Savings:     $80/month (-44%)
#
# With 1-year RI: $60/month (-67% vs unoptimized)
# With 3-year RI: $45/month (-75% vs unoptimized)
