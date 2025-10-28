# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- Full test coverage with Terraform native tests
- Complete documentation and examples
- GitHub Actions CI/CD pipeline

[unreleased]: https://github.com/org/terraform-azurerm-windows-virtual-machine/compare/v0.1.0...HEAD
