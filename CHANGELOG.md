# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2025-10-30

### Added
- Initial module creation for Windows Virtual Machines
- Support for Windows Server 2019/2022 Datacenter editions
- Network interface creation with private IP configuration
- Optional public IP address support
- Encrypted managed disks (OS disk + optional data disks)
- Secure Boot and vTPM for Generation 2 VMs
- Boot diagnostics with storage account integration
- System-assigned managed identity support
- Availability zones and availability sets support
- Azure Monitor Agent extension
- Dependency Agent extension
- Microsoft Antimalware extension
- BGInfo extension
- Azure Hybrid Benefit licensing support
- Automatic patching configuration
- Random password generation for admin credentials
- Comprehensive input validation
- Complete documentation and examples
- GitHub Actions CI/CD pipeline
- **Cost optimization examples** (`examples/cost-optimized` and `examples/production`)
- **Comprehensive cost optimization guide** (COST_OPTIMIZATION.md)
  - VM size recommendations (B-series, AMD-based VMs)
  - Azure Hybrid Benefit guidance (40-50% savings)
  - Reserved Instance strategies (31-51% savings)
  - Disk optimization strategies (55-73% savings)
  - Auto-shutdown configuration for dev/test
  - Monitoring cost controls
  - Multi-environment cost strategies
- **🔐 Customer-Managed Key (CMK) encryption** via `disk_encryption_set_id` parameter
  - Supports encryption with customer-managed keys stored in Azure Key Vault
  - Required for HIPAA, PCI-DSS Level 1, and FedRAMP compliance
  - Applies to both OS disk and all data disks
- **🔐 Encryption at host** via `enable_encryption_at_host` parameter
  - Double encryption (encryption at VM host/hypervisor level AND server-side)
  - Defense-in-depth against VM escape vulnerabilities
  - Required for Azure Confidential Computing
- **Enhanced test coverage** - Expanded from 11 to 41 comprehensive tests (273% increase)
  - 18 advanced functionality tests (including 4 encryption tests)
  - 20 validation tests
  - 3 basic tests
  - 100% feature coverage

[unreleased]: https://github.com/hatboyzero/terraform-azurerm-windows-virtual-machine/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/hatboyzero/terraform-azurerm-windows-virtual-machine/releases/tag/v0.0.1
