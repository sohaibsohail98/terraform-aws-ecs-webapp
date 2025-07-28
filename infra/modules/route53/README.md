# Route53 Module

Creates a Route53 hosted zone for DNS management. DNS records and associations are handled in the main configuration.

## Purpose

This module creates the foundational DNS infrastructure by setting up a hosted zone. All DNS records (A records, certificate validation records) are managed in `main.tf` to avoid circular dependencies.

## Resources Created

- **Route53 Hosted Zone**: DNS zone for domain management

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `route53_zone_name` | string | Domain name for the hosted zone |

## Outputs

| Output | Description |
|--------|-------------|
| `zone_id` | Route53 hosted zone ID |
| `zone_name_servers` | Name servers for domain configuration |

## DNS Management

### Hosted Zone Features
- **Domain Management**: Authoritative DNS for your domain
- **Name Server Delegation**: AWS-managed name servers
- **Record Management**: Foundation for DNS records
- **Integration**: Works with ACM validation and ALB routing

## Example Usage

```hcl
module "route53" {
  source = "./modules/route53"

  route53_zone_name = "example.com"
}
```

## DNS Records Created in Main.tf

The main configuration creates:

1. **Certificate Validation Records**: CNAME records for ACM validation
2. **A Records**: Alias records pointing to load balancer
3. **Certificate Validation Resource**: Waits for DNS validation

This separation ensures proper dependency ordering:
Route53 Zone → Certificate Validation → HTTPS Listener

## Domain Setup

### After Deployment
1. **Note Name Servers**: Check the `zone_name_servers` output
2. **Update Domain Registrar**: Point your domain to these name servers
3. **DNS Propagation**: Wait for DNS propagation (up to 48 hours)
4. **Certificate Validation**: ACM will validate once DNS propagates

### Name Server Configuration
```bash
# Get name servers from Terraform output
terraform output route53_name_servers

# Example output:
# [
#   "ns-1234.awsdns-12.com",
#   "ns-5678.awsdns-34.net",
#   "ns-9012.awsdns-56.org", 
#   "ns-3456.awsdns-78.co.uk"
# ]
```

## Dependencies

- **Domain Registration**: Must own the domain being managed
- **Registrar Access**: Need access to update name servers

## Security Features

- **DNSSEC Support**: Optional DNSSEC signing
- **Access Control**: IAM-based DNS management
- **Audit Trail**: CloudTrail logging of DNS changes
- **Health Checks**: Optional health check integration

## Best Practices

- Use consistent domain naming
- Monitor DNS resolution
- Set appropriate TTL values
- Use Route53 health checks for failover
- Tag resources for management

## Common Patterns

### Root Domain
```hcl
route53_zone_name = "example.com"
```

### Subdomain Delegation
```hcl
route53_zone_name = "staging.example.com"
```

### Environment-Specific
```hcl
route53_zone_name = "dev.mycompany.com"
```

## Troubleshooting

### Certificate Validation Issues
1. **Check Name Servers**: Ensure domain points to Route53 name servers
2. **DNS Propagation**: Use `dig` or `nslookup` to verify DNS
3. **Validation Records**: Confirm CNAME records exist in hosted zone

### DNS Resolution Problems
1. **TTL Values**: Check if old DNS is cached
2. **Propagation**: Wait for global DNS propagation
3. **Name Server**: Verify correct name server configuration

## Integration

This module provides the foundation for:
- **ACM Certificate Validation**: DNS-based domain validation
- **Load Balancer Routing**: A records pointing to ALB
- **Application Access**: User-friendly domain names
- **Email Services**: MX records for email routing