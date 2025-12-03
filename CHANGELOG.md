# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-28

### Added

- Initial release of AWS Routes Terraform module
- Flexible route creation with map-based configuration
- Support for all AWS route targets:
  - NAT Gateway
  - Transit Gateway
  - VPC Peering Connection
  - Network Interface
  - VPC Endpoint
  - Egress-Only Gateway
  - Internet/VPN Gateway
  - Local Gateway
  - Carrier Gateway
  - Core Network ARN
- Support for IPv4 CIDR, IPv6 CIDR, and Prefix List destinations
- Input validation for destinations and targets
- CI pipeline with terraform fmt, validate, tflint, and tfsec
- MIT License

[1.0.0]: https://github.com/gebalamariusz/terraform-aws-routes/releases/tag/v1.0.0
