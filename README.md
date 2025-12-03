# AWS Routes Terraform Module

[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-gebalamariusz%2Froutes%2Faws-blue?logo=terraform)](https://registry.terraform.io/modules/gebalamariusz/routes/aws)
[![CI](https://github.com/gebalamariusz/terraform-aws-routes/actions/workflows/ci.yml/badge.svg)](https://github.com/gebalamariusz/terraform-aws-routes/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/gebalamariusz/terraform-aws-routes?display_name=tag&sort=semver)](https://github.com/gebalamariusz/terraform-aws-routes/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.7-purple.svg)](https://www.terraform.io/)

Terraform module to create VPC routes with flexible target support.

This module is designed to work seamlessly with [terraform-aws-vpc](https://github.com/gebalamariusz/terraform-aws-vpc), [terraform-aws-subnets](https://github.com/gebalamariusz/terraform-aws-subnets), and [terraform-aws-nat-gateway](https://github.com/gebalamariusz/terraform-aws-nat-gateway) modules.

## Architecture

```
terraform-aws-vpc          -> VPC, IGW
        |
terraform-aws-subnets      -> Subnets, Route Tables, IGW routes (public)
        |
terraform-aws-nat-gateway  -> NAT, EIP
        |
terraform-aws-routes       -> Routes (0.0.0.0/0 -> NAT, TGW, VPC Peering, VPN, etc.)  <-- This module
```

## Features

- Flexible route creation using map-based configuration
- Support for all AWS route targets:
  - NAT Gateway
  - Transit Gateway
  - VPC Peering Connection
  - Network Interface
  - VPC Endpoint
  - Egress-Only Gateway (IPv6)
  - Internet Gateway / VPN Gateway
  - Local Gateway
  - Carrier Gateway
  - Core Network ARN
- Support for IPv4 CIDR, IPv6 CIDR, and Prefix List destinations
- Input validation for destinations and targets

## Usage

### Route private subnets to NAT Gateway

```hcl
module "vpc" {
  source  = "gebalamariusz/vpc/aws"
  version = "~> 1.0"

  name       = "my-app"
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source  = "gebalamariusz/subnets/aws"
  version = "~> 1.0"

  name   = "my-app"
  vpc_id = module.vpc.vpc_id

  subnets = {
    "10.0.1.0/24" = { az = "eu-west-1a", tier = "public",  public = true }
    "10.0.2.0/24" = { az = "eu-west-1b", tier = "public",  public = true }
    "10.0.3.0/24" = { az = "eu-west-1a", tier = "private", public = false }
    "10.0.4.0/24" = { az = "eu-west-1b", tier = "private", public = false }
  }
}

module "nat_gateway" {
  source  = "gebalamariusz/nat-gateway/aws"
  version = "~> 1.0"

  name               = "my-app"
  subnet_ids         = module.subnets.subnet_ids_by_tier["public"]
  single_nat_gateway = true
}

module "routes" {
  source  = "gebalamariusz/routes/aws"
  version = "~> 1.0"

  routes = {
    "private-to-nat" = {
      route_table_id         = module.subnets.route_table_ids_by_tier["private"]
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id         = module.nat_gateway.nat_gateway_ids[0]
    }
  }
}
```

### Multiple routes with different targets

```hcl
module "routes" {
  source  = "gebalamariusz/routes/aws"
  version = "~> 1.0"

  routes = {
    # Route to NAT Gateway for internet access
    "private-to-nat" = {
      route_table_id         = "rtb-private"
      destination_cidr_block = "0.0.0.0/0"
      nat_gateway_id         = "nat-xxx"
    }

    # Route to Transit Gateway for on-prem connectivity
    "private-to-onprem" = {
      route_table_id         = "rtb-private"
      destination_cidr_block = "10.0.0.0/8"
      transit_gateway_id     = "tgw-xxx"
    }

    # Route to VPC Peering for cross-VPC communication
    "private-to-shared" = {
      route_table_id            = "rtb-private"
      destination_cidr_block    = "172.16.0.0/16"
      vpc_peering_connection_id = "pcx-xxx"
    }

    # Route to VPN Gateway
    "private-to-vpn" = {
      route_table_id         = "rtb-private"
      destination_cidr_block = "192.168.0.0/16"
      gateway_id             = "vgw-xxx"
    }
  }
}
```

### IPv6 routes with Egress-Only Gateway

```hcl
module "routes" {
  source  = "gebalamariusz/routes/aws"
  version = "~> 1.0"

  routes = {
    "private-ipv6-egress" = {
      route_table_id              = "rtb-private"
      destination_ipv6_cidr_block = "::/0"
      egress_only_gateway_id      = "eigw-xxx"
    }
  }
}
```

### Using Prefix Lists

```hcl
module "routes" {
  source  = "gebalamariusz/routes/aws"
  version = "~> 1.0"

  routes = {
    "to-s3-endpoint" = {
      route_table_id             = "rtb-private"
      destination_prefix_list_id = "pl-xxx"  # S3 prefix list
      vpc_endpoint_id            = "vpce-xxx"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| routes | Map of routes to create. Each route must specify route_table_id, destination, and exactly one target. | `map(object({...}))` | n/a | yes |

### Route Object Structure

| Attribute | Description | Type | Required |
|-----------|-------------|------|:--------:|
| route_table_id | Route table ID to add the route to | `string` | yes |
| destination_cidr_block | IPv4 destination CIDR | `string` | one of destination* |
| destination_ipv6_cidr_block | IPv6 destination CIDR | `string` | one of destination* |
| destination_prefix_list_id | Managed prefix list destination | `string` | one of destination* |
| nat_gateway_id | NAT Gateway target | `string` | one of targets |
| transit_gateway_id | Transit Gateway target | `string` | one of targets |
| vpc_peering_connection_id | VPC Peering target | `string` | one of targets |
| network_interface_id | ENI target | `string` | one of targets |
| vpc_endpoint_id | VPC Endpoint target | `string` | one of targets |
| egress_only_gateway_id | Egress-Only Gateway target (IPv6) | `string` | one of targets |
| gateway_id | Internet Gateway or VPN Gateway target | `string` | one of targets |
| local_gateway_id | Local Gateway target (Outposts) | `string` | one of targets |
| carrier_gateway_id | Carrier Gateway target (Wavelength) | `string` | one of targets |
| core_network_arn | Core Network ARN target (Cloud WAN) | `string` | one of targets |

## Outputs

| Name | Description |
|------|-------------|
| route_ids | Map of route keys to their route IDs |
| routes | Map of all route attributes |

## License

MIT
