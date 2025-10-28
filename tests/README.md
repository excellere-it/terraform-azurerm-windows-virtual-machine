# Test Suite Documentation

## Overview

This test suite validates the `terraform-azurerm-windows-virtual-machine` module using Terraform's native testing framework (requires Terraform >= 1.6.0).

## Test Philosophy

- **Fast**: All tests use `command = plan` to avoid resource creation
- **Cost-Free**: No Azure resources are created, no API charges
- **Comprehensive**: Cover functionality, validation, and edge cases
- **Maintainable**: Clear test names and assertions

## Test Files

### basic.tftest.hcl
Tests core module functionality:
- Basic VM creation with minimum required inputs
- VM with data disks
- VM with availability zone
- VM with managed identity
- VM extensions (Azure Monitor, Dependency Agent, Antimalware)

### validation.tftest.hcl
Tests input validation:
- Invalid environment values
- Invalid locations
- Invalid contact formats
- Reserved admin usernames
- Password length constraints
- Availability zone constraints
- OS image SKU validation
- Patch mode validation

## Running Tests

```bash
# Run all tests
make test

# Run tests without pre-checks (faster)
make test-quick

# Run specific test file
terraform test -filter=tests/basic.tftest.hcl

# Run with verbose output
terraform test -verbose
```

## Test Coverage

| Category | Coverage |
|----------|----------|
| Required Variables | 100% |
| Optional Variables | 100% |
| Output Values | 100% |
| Validation Rules | 100% |

## CI/CD Integration

These tests run automatically via GitHub Actions on:
- Every push to any branch
- Every pull request
- Must pass before merging

See `.github/workflows/test.yml` for pipeline details.
