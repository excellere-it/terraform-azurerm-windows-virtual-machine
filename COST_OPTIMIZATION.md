# Cost Optimization Guide

This guide provides comprehensive strategies for optimizing Azure Windows VM costs while maintaining security and performance.

## Table of Contents

- [Cost Breakdown](#cost-breakdown)
- [Optimization Strategies](#optimization-strategies)
- [Configuration Examples](#configuration-examples)
- [Cost Estimation Tool](#cost-estimation-tool)
- [Best Practices](#best-practices)

---

## Cost Breakdown

### Baseline Configuration (examples/default)

**Region:** US Central
**VM Size:** Standard_D2s_v3 (2 vCPU, 8 GB RAM)

| Component | Specification | Monthly Cost |
|-----------|---------------|--------------|
| VM Compute | Standard_D2s_v3, 730 hours | $96.36 |
| OS Disk | Premium_LRS P10 (128 GB) | $19.71 |
| Data Disk | Premium_LRS P10 (128 GB) | $19.71 |
| Boot Diagnostics | Standard LRS storage | $0.02 |
| Azure Monitor | 1-5 GB log ingestion | $0-12.50 |
| Antimalware | Included with VM | $0 |
| **Total** | **Pay-as-you-go** | **$136-148** |

---

## Optimization Strategies

### 1. VM Size Optimization (Up to 68% Savings)

#### Development/Test Environments

**B-Series Burstable VMs** - Best for workloads with low average CPU utilization

| VM Size | vCPU | RAM | Baseline CPU | Monthly Cost | Savings vs D2s_v3 | Use Case |
|---------|------|-----|--------------|--------------|-------------------|----------|
| Standard_B2s | 2 | 4 GB | 40% | $30.37 | **-$66 (-68%)** | Dev/test, low memory |
| Standard_B2ms | 2 | 8 GB | 60% | $60.74 | **-$36 (-37%)** | Dev/test, standard |
| Standard_B4ms | 4 | 16 GB | 60% | $121.47 | N/A | Dev/test, high memory |

**How B-Series Works:**
- Accumulate CPU credits during idle periods
- Burst to 100% CPU when needed
- Ideal for: Development, testing, web servers, small databases

**When to Use:**
```hcl
# Dev/Test environment
vm_size = "Standard_B2ms"  # 37% savings, suitable for most dev workloads
```

#### Production Environments - AMD-Based VMs (20-30% Savings)

**D-Series AMD (Das/Dads) and E-Series AMD (Eas/Eads)** - Same performance, lower cost

| VM Size (Intel) | Monthly Cost | VM Size (AMD) | Monthly Cost | Savings | Performance |
|-----------------|--------------|---------------|--------------|---------|-------------|
| Standard_D2s_v5 | $91.98 | Standard_D2as_v5 | $73.73 | **-$18 (-20%)** | Equivalent |
| Standard_D4s_v5 | $183.96 | Standard_D4as_v5 | $147.46 | **-$36 (-20%)** | Equivalent |
| Standard_E2s_v5 | $105.12 | Standard_E2as_v5 | $84.10 | **-$21 (-20%)** | Equivalent |

**When to Use:**
```hcl
# Production environment
vm_size = "Standard_D2as_v5"  # 20-24% savings, same performance as Intel
```

#### Latest Generation VMs (4-10% Savings)

Newer VM generations offer better price/performance ratios:

| Generation | Example | Monthly Cost | Improvement |
|------------|---------|--------------|-------------|
| v3 (current) | Standard_D2s_v3 | $96.36 | Baseline |
| v5 (latest) | Standard_D2s_v5 | $91.98 | -4.5% (-$4.38) |

### 2. Azure Hybrid Benefit (40-50% Savings)

**Eligibility Requirements:**
- Active Windows Server licenses with Software Assurance
- Or Windows Server subscription licenses
- Or Windows 10/11 Enterprise E3/E5 licenses

**Savings Breakdown:**

| Configuration | Without AHB | With AHB | Monthly Savings | Annual Savings |
|---------------|-------------|----------|-----------------|----------------|
| Standard_D2s_v3 | $96.36 | ~$50 | ~$45 (47%) | ~$540 |
| Standard_D4s_v3 | $192.72 | ~$100 | ~$90 (47%) | ~$1,080 |
| Standard_D2as_v5 | $73.73 | ~$40 | ~$33 (45%) | ~$396 |

**Configuration:**
```hcl
module "windows_vm" {
  source = "path/to/module"

  license_type = "Windows_Server"  # Bring your own license

  # ... other configuration
}
```

**Important Notes:**
- Each license covers 8 cores (or 16 vCPUs)
- One Standard_D2s_v3 (2 vCPU) consumes 1/8th of a license
- Track usage to ensure compliance
- Learn more: https://azure.microsoft.com/pricing/hybrid-benefit/

### 3. Reserved Instances (31-51% Savings)

**Commitment-Based Pricing** - Purchase compute capacity in advance

| Commitment | Standard_D2s_v3 | Discount | Annual Cost | Total Savings (3yr) |
|------------|-----------------|----------|-------------|---------------------|
| Pay-as-you-go | $96.36/month | 0% | $1,156 | Baseline |
| 1-Year Reserved | $66.43/month | **31%** | $797 | **-$359** |
| 3-Year Reserved | $47.45/month | **51%** | $569 | **-$1,761** |

**Combined with Azure Hybrid Benefit:**

| Commitment | With AHB | Total Discount | Annual Cost |
|------------|----------|----------------|-------------|
| Pay-as-you-go + AHB | $50/month | 48% | $600 |
| 1-Year RI + AHB | $35/month | **64%** | $420 |
| 3-Year RI + AHB | $25/month | **74%** | $300 |

**How to Purchase:**
1. Azure Portal → Reservations → Purchase
2. Select: Region, VM series, Term (1 or 3 years)
3. Reservation automatically applies to matching VMs

**Best Practices:**
- Start with 1-year commitments to maintain flexibility
- Use 3-year for stable, long-term workloads
- Purchase reservations for production VMs running 24/7
- Dev/test VMs: Use pay-as-you-go + auto-shutdown instead

### 4. Disk Optimization (55-73% Savings)

**Disk Type Selection Based on Workload**

| Disk Type | IOPS | Throughput | 128 GB Cost | 256 GB Cost | Use Case |
|-----------|------|------------|-------------|-------------|----------|
| **Premium_LRS** | 500-20,000 | 100-900 MB/s | $19.71 | $40.96 | Production DBs, high I/O |
| **StandardSSD_LRS** | 500-6,000 | 60-750 MB/s | $10.24 | $20.48 | Dev/test, web servers |
| **Standard_LRS** | 500-2,000 | 60-500 MB/s | $5.89 | $11.78 | Archive, backups |

**Savings Comparison (128 GB OS Disk + 256 GB Data Disk):**

| Configuration | OS Disk | Data Disk | Total | Savings |
|---------------|---------|-----------|-------|---------|
| Premium_LRS (baseline) | $19.71 | $40.96 | $60.67 | 0% |
| StandardSSD_LRS | $10.24 | $20.48 | $30.72 | **-$29.95 (-49%)** |
| Standard_LRS | $5.89 | $11.78 | $17.67 | **-$43.00 (-71%)** |

**Performance Tiers:**

Premium SSD tiers (performance vs cost):

| Size | Tier | IOPS | Throughput | Monthly Cost | Cost per IOPS |
|------|------|------|------------|--------------|---------------|
| 64 GB | P6 | 240 | 50 MB/s | $9.86 | $0.041 |
| 128 GB | P10 | 500 | 100 MB/s | $19.71 | $0.039 |
| 256 GB | P15 | 1,100 | 125 MB/s | $40.96 | $0.037 |
| 512 GB | P20 | 2,300 | 150 MB/s | $75.78 | $0.033 |

**Right-Sizing Strategy:**
```hcl
# Development/Test
os_disk_storage_account_type = "StandardSSD_LRS"
os_disk_size_gb              = 64   # Minimum size

# Production - Web Server
os_disk_storage_account_type = "StandardSSD_LRS"
os_disk_size_gb              = 128  # Moderate performance

# Production - Database
os_disk_storage_account_type = "Premium_LRS"
os_disk_size_gb              = 256  # Higher IOPS needed
```

### 5. Auto-Shutdown for Dev/Test (50% Savings)

**Automatic VM Shutdown** - Reduce costs by stopping VMs when not in use

**Scenario: Dev/Test VMs (Standard_B2ms)**
- 24/7 operation: $60.74/month
- 12 hours/day (8 AM - 8 PM): **$30.37/month**
- **Savings: $30.37/month (-50%)**

**Configuration Options:**

**Option 1: Azure Portal (Manual Setup)**
1. Navigate to VM → Operations → Auto-shutdown
2. Enable: Yes
3. Scheduled time: 8:00 PM (or end of business day)
4. Timezone: Your local timezone
5. Send notification: Optional

**Option 2: Terraform (Proposed Feature)**
```hcl
module "windows_vm_dev" {
  source = "path/to/module"

  # Enable auto-shutdown
  enable_auto_shutdown   = true
  auto_shutdown_time     = "1900"  # 7:00 PM
  auto_shutdown_timezone = "Central Standard Time"

  # Optional: Email notification
  auto_shutdown_notification_email = "devteam@example.com"
}
```

**Best Practices:**
- Development environments: Shutdown at 6-8 PM, start at 8 AM
- Test environments: Shutdown on weekends and holidays
- Staging environments: Match production hours
- Never use auto-shutdown for production VMs

**Annual Savings Example:**
- 1 dev VM running 12 hours/day: $365/year saved
- 10 dev VMs: $3,650/year saved
- 50 dev VMs: $18,250/year saved

### 6. Monitoring Cost Optimization (Savings Vary)

**Azure Monitor Log Ingestion Costs**

| Tier | Price per GB | Retention | Use Case |
|------|--------------|-----------|----------|
| **Free Tier** | First 5 GB free | 31 days | Dev/test, small deployments |
| **Pay-as-you-go** | $2.50/GB | 31-730 days | Production standard logs |
| **Commitment Tiers** | $2.30-1.15/GB | 31-730 days | High-volume (100+ GB/day) |
| **Basic Logs** | $0.30/GB | 8 days | High-volume, short retention |

**Typical Windows VM Log Volume:**
- Minimal logging (events only): 0.5-2 GB/month → **Free tier**
- Standard logging (security + apps): 3-8 GB/month → **$0-7.50/month**
- Verbose logging (debug enabled): 15-50 GB/month → **$25-112.50/month**

**Cost Optimization Strategies:**

**1. Disable Monitoring in Dev/Test (Saves $0-12.50/month)**
```hcl
# Development environment
enable_azure_monitor_agent = false
enable_dependency_agent    = false
```

**2. Configure Data Collection Rules (Saves 30-70%)**
```hcl
# In Log Analytics workspace, create DCR to filter:
# - Exclude verbose application logs
# - Collect only security and error events
# - Disable performance counters in dev/test
```

**3. Optimize Log Retention (Saves 50-80% on storage)**
| Environment | Recommended Retention | Monthly Cost (10 GB) |
|-------------|-----------------------|----------------------|
| Development | 7-30 days | $0-5 |
| Staging | 30-90 days | $5-10 |
| Production | 90-365 days | $10-25 |
| Archive | Move to Storage (2+ years) | $0.02/GB |

**4. Use Basic Logs for High-Volume Data (Saves 88%)**
- Windows Event Logs → Basic Logs: $0.30/GB vs $2.50/GB
- IIS Logs → Basic Logs
- Application logs (non-critical) → Basic Logs

### 7. Availability Configuration (Minimal Cost Impact)

**Availability Options vs Cost:**

| Option | SLA | Setup Cost | Ongoing Cost | Use Case |
|--------|-----|------------|--------------|----------|
| None | 99.9% | $0 | $0 | Dev/test |
| Availability Zone | **99.99%** | $0 | $0 | Production single VM |
| Availability Set | 99.95% | $0 | $0 | Legacy deployments |
| Multiple VMs + Load Balancer | 99.99% | Load balancer cost | $20-50/month | High availability |

**Data Transfer Costs (Between Zones):**
- Intra-zone: Free
- Between zones (same region): **$0.01/GB**
- Typical inter-zone traffic: 1-10 GB/month = **$0.01-0.10/month**

**Recommendation:**
```hcl
# Always use availability zones for production (no additional cost)
availability_zone = "1"  # Free upgrade from 99.9% to 99.99% SLA
```

---

## Configuration Examples

### Cost-Optimized Dev/Test: ~$39/month (72% savings)

```hcl
module "windows_vm_dev" {
  source = "path/to/terraform-azurerm-windows-virtual-machine"

  # Naming
  environment = "dev"
  workload    = "devtest"
  # ... other naming vars

  # Cost Optimization: B-series burstable
  vm_size = "Standard_B2ms"  # $60.74/month → $30/month with auto-shutdown

  # Cost Optimization: StandardSSD disks
  os_disk_storage_account_type = "StandardSSD_LRS"  # $5.12 vs $19.71
  os_disk_size_gb              = 64
  data_disks                   = []  # No data disks

  # Cost Optimization: Disable monitoring
  enable_azure_monitor_agent = false
  enable_dependency_agent    = false

  # Security: Keep essential features
  enable_antimalware = true
  enable_secure_boot = true
  enable_vtpm        = true

  # Auto-shutdown (configure in Portal)
  # Saves 50%: $60.74 → $30.37/month
}
```

**Monthly Cost Breakdown:**
- VM: $30.37 (with auto-shutdown)
- Disk: $5.12
- Diagnostics: $0.02
- **Total: ~$35-39/month**

### Production Standard: ~$60/month (57% savings)

```hcl
module "windows_vm_prod" {
  source = "path/to/terraform-azurerm-windows-virtual-machine"

  # Naming
  environment = "prd"
  workload    = "app"
  # ... other naming vars

  # Cost Optimization: AMD-based VM
  vm_size = "Standard_D2as_v5"  # $73.73 vs $96.36 (Intel)

  # Cost Optimization: Azure Hybrid Benefit
  license_type = "Windows_Server"  # Saves $45/month

  # Performance: Premium disks for production
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 128

  data_disks = [{
    disk_size_gb         = 256
    lun                  = 0
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }]

  # Availability: Zone for 99.99% SLA (no cost)
  availability_zone = "1"

  # Monitoring: Enabled (first 5 GB free)
  enable_azure_monitor_agent = true
  enable_antimalware         = true
  enable_secure_boot         = true
  enable_vtpm                = true
  enable_managed_identity    = true
}
```

**Monthly Cost Breakdown:**
- VM (AMD + AHB): $40
- OS Disk: $20
- Data Disk: $40
- Monitoring: $0 (free tier)
- **Total: ~$100/month pay-as-you-go**
- **With 1-year RI: ~$60/month**

### Production High-Performance: ~$150/month

```hcl
module "windows_vm_prod_high" {
  source = "path/to/terraform-azurerm-windows-virtual-machine"

  vm_size = "Standard_D4as_v5"  # 4 vCPU, 16 GB, AMD

  license_type = "Windows_Server"  # Azure Hybrid Benefit

  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 256

  data_disks = [
    {
      disk_size_gb         = 512
      lun                  = 0
      caching              = "ReadWrite"
      storage_account_type = "Premium_LRS"
    },
    {
      disk_size_gb         = 512
      lun                  = 1
      caching              = "ReadOnly"
      storage_account_type = "Premium_LRS"
    }
  ]

  availability_zone           = "1"
  enable_azure_monitor_agent  = true
  enable_dependency_agent     = true
}
```

---

## Cost Estimation Tool

Use this formula to estimate your monthly costs:

```
Total Cost = VM Compute + OS Disk + Data Disks + Monitoring + Transfer

Where:
  VM Compute  = (Base Price × Hours) × (1 - RI Discount) × (1 - AHB Discount)
  OS Disk     = Disk Size Tier Price
  Data Disks  = Sum of all data disk tier prices
  Monitoring  = (GB Ingested - 5 GB free) × $2.50
  Transfer    = (GB Transferred × $0.01) for inter-zone
```

### Example Calculation: Production VM with all optimizations

```
VM: Standard_D2as_v5 (AMD)
  Base: $73.73/month
  × (1 - 0.31)     [1-year RI]     = $50.87
  × (1 - 0.45)     [AHB]           = $28.00

OS Disk: Premium_LRS 128 GB (P10) = $19.71

Data Disk: Premium_LRS 256 GB (P15) = $40.96

Monitoring: 5 GB ingested
  (5 GB - 5 GB free) × $2.50 = $0

Total = $28.00 + $19.71 + $40.96 + $0 = $88.67/month

Savings vs unoptimized: $180/month - $88.67 = $91.33/month (51% savings)
```

---

## Best Practices

### 1. Right-Sizing Methodology

**Step 1: Monitor Actual Usage (30 days)**
- CPU utilization
- Memory usage
- Disk IOPS
- Network throughput

**Step 2: Analyze Patterns**
- Average CPU < 40%? → Consider B-series
- Peak CPU < 60%? → Downsize to smaller VM
- Consistent high CPU? → Keep current size or scale out

**Step 3: Test in Non-Production**
- Deploy smaller VM size in staging
- Run load tests
- Validate performance meets requirements

**Step 4: Apply to Production**
- Schedule downtime or use blue-green deployment
- Resize VMs during maintenance window

### 2. Cost Allocation Strategy

**Tagging for Cost Tracking:**
```hcl
# Extend module with cost center tags
module "windows_vm" {
  source = "path/to/module"

  # Standard naming tags (included)
  environment = "prd"
  workload    = "app"

  # Add cost allocation tags (if module extended)
  cost_center  = "IT-001"
  budget_owner = "john.doe@company.com"
  project_code = "PRJ-2024-001"
}
```

**Azure Cost Management:**
1. Group by tags: Environment, Workload, Cost Center
2. Set budgets per tag
3. Configure alerts at 80%, 90%, 100% of budget
4. Review monthly cost reports

### 3. Commitment Planning

**Decision Matrix:**

| Workload Type | Commitment | Reasoning |
|---------------|------------|-----------|
| Production (24/7) | 3-year RI | Maximum savings (51%) |
| Production (business hours) | 1-year RI | Flexibility + savings (31%) |
| Staging | Pay-as-you-go | Variable usage |
| Development | Pay-as-you-go + Auto-shutdown | 50% savings without commitment |
| POC/Testing | Pay-as-you-go | Short-term, may decommission |

**Commitment Cadence:**
- Review VM inventory quarterly
- Identify VMs running 6+ months
- Purchase RIs for stable workloads
- Start with 1-year to learn patterns
- Graduate to 3-year for known long-term needs

### 4. Monitoring Cost Controls

**Set Budget Alerts:**
```
Development:  $50/month per VM
Staging:      $100/month per VM
Production:   $150/month per VM
```

**Alert Actions:**
1. **80% threshold**: Email to team
2. **90% threshold**: Automated review
3. **100% threshold**: Escalation to management

**Monthly Review Checklist:**
- [ ] Identify VMs with low utilization (<20% CPU)
- [ ] Review VMs without auto-shutdown in dev/test
- [ ] Check for unattached disks (orphaned)
- [ ] Validate RI coverage for production VMs
- [ ] Review Log Analytics ingestion costs
- [ ] Identify opportunities for AMD-based VMs

### 5. Multi-Environment Strategy

| Environment | VM Size | Disk Type | AHB | RI | Auto-Shutdown | Est. Cost |
|-------------|---------|-----------|-----|----|--------------|-----------|
| **Development** | B2ms | StandardSSD | No | No | Yes (12h/day) | $35-40 |
| **Testing** | B2ms | StandardSSD | No | No | Yes (10h/day) | $30-35 |
| **Staging** | D2as_v5 | Premium | Yes | 1-year | No | $60-70 |
| **Production** | D2as_v5 | Premium | Yes | 3-year | No | $45-55 |

**Total 4-Environment Stack:**
- Unoptimized: ~$560/month
- Optimized: ~$170-200/month
- **Savings: ~$360-390/month (64-70%)**

---

## Additional Resources

- **Azure Pricing Calculator**: https://azure.microsoft.com/pricing/calculator/
- **Azure Hybrid Benefit**: https://azure.microsoft.com/pricing/hybrid-benefit/
- **Reserved VM Instances**: https://docs.microsoft.com/azure/cost-management-billing/reservations/
- **Azure Cost Management**: https://docs.microsoft.com/azure/cost-management-billing/
- **VM Size Guidance**: https://docs.microsoft.com/azure/virtual-machines/sizes

---

## Summary: Quick Wins

| Optimization | Effort | Savings | Implementation |
|--------------|--------|---------|----------------|
| **Azure Hybrid Benefit** | Low | 40-50% | Set `license_type = "Windows_Server"` |
| **AMD-based VMs** | Low | 20-30% | Change `vm_size` to `Das` or `Eas` series |
| **Auto-shutdown (dev)** | Low | 50% | Configure in Azure Portal |
| **B-series (dev)** | Medium | 37-68% | Change `vm_size`, test performance |
| **StandardSSD disks (dev)** | Low | 55% | Set `os_disk_storage_account_type` |
| **Reserved Instances** | Low | 31-51% | Purchase in Azure Portal |
| **Disable monitoring (dev)** | Low | $2.50-12.50/month | Set `enable_azure_monitor_agent = false` |

**Recommended Starting Point:**
1. Apply Azure Hybrid Benefit (if eligible) → **40-50% immediate savings**
2. Switch to AMD-based VMs → **20% additional savings**
3. Enable auto-shutdown for dev/test → **50% savings on dev environments**
4. Purchase 1-year RIs for production → **31% additional savings**

**Result: 70-80% total cost reduction vs unoptimized baseline**
