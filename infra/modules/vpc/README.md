# VPC Module

Creates a secure, multi-AZ VPC with public and private subnets, NAT gateways, and proper routing for ECS workloads.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet Gateway                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│  Public Subnets (Multi-AZ)                                   │
│  ├── ALB                                                     │
│  ├── NAT Gateway 1 (AZ-a)                                    │
│  └── NAT Gateway 2 (AZ-b)                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│  Private Subnets (Multi-AZ)                                  │
│  ├── ECS Tasks (AZ-a) → NAT Gateway 1                       │
│  └── ECS Tasks (AZ-b) → NAT Gateway 2                       │
└─────────────────────────────────────────────────────────────┘
```

## Resources Created

- **VPC**: Main virtual private cloud
- **Internet Gateway**: Internet access for public subnets
- **Public Subnets**: For load balancers and NAT gateways (2 AZs)
- **Private Subnets**: For ECS tasks (2 AZs)
- **NAT Gateways**: Outbound internet access for private subnets (2 for HA)
- **Elastic IPs**: For NAT gateways
- **Route Tables**: Public and private routing
- **Route Table Associations**: Subnet to route table mappings

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `vpc_cidr` | string | CIDR block for the VPC |
| `public_subnets` | map(object) | Map of public subnet configurations |
| `private_subnets` | map(object) | Map of private subnet configurations |

### Subnet Configuration Format

```hcl
public_subnets = {
  public1 = {
    cidr     = "10.0.1.0/24"
    az_index = 0
  }
  public2 = {
    cidr     = "10.0.2.0/24"
    az_index = 1
  }
}

private_subnets = {
  private1 = {
    cidr     = "10.0.11.0/24"
    az_index = 0
  }
  private2 = {
    cidr     = "10.0.12.0/24"
    az_index = 1
  }
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the created VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `internet_gateway_id` | Internet Gateway ID |
| `nat_gateway_ids` | Map of NAT Gateway IDs |

## Security Features

- **Network Isolation**: Separate public and private subnets
- **High Availability**: Multi-AZ deployment
- **Outbound Only**: Private subnets have outbound internet via NAT
- **No Direct Internet**: Private subnets cannot receive inbound traffic from internet

## Best Practices

- Uses 2 availability zones for high availability
- NAT gateways in each AZ to avoid single point of failure
- Proper CIDR sizing for future growth
- Tag-based resource management

## Example Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"
  
  public_subnets = {
    public1 = {
      cidr     = "10.0.1.0/24"
      az_index = 0
    }
    public2 = {
      cidr     = "10.0.2.0/24"
      az_index = 1
    }
  }

  private_subnets = {
    private1 = {
      cidr     = "10.0.11.0/24"
      az_index = 0
    }
    private2 = {
      cidr     = "10.0.12.0/24"
      az_index = 1
    }
  }
}
```

## Dependencies

- No external dependencies
- Creates foundational networking for other modules