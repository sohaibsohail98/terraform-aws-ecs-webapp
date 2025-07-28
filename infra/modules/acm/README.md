# ACM Module

Creates SSL/TLS certificates for HTTPS-enabled applications using AWS Certificate Manager.

## Purpose

This module creates ACM certificates for domain validation. Certificate validation and DNS records are handled in the main configuration to avoid circular dependencies.

## Resources Created

- **ACM Certificate**: SSL/TLS certificate for domain and subdomains

## Inputs

| Variable | Type | Description |
|----------|------|-------------|
| `domain_name` | string | Primary domain name for certificate |
| `subject_alternative_names` | list(string) | Additional domain names |
| `app_name` | string | Application name for tagging |
| `environment` | string | Environment name for tagging |

## Outputs

| Output | Description |
|--------|-------------|
| `certificate_arn` | ARN of the ACM certificate |
| `certificate_domain_name` | Primary domain name |
| `certificate_status` | Certificate status |
| `domain_validation_options` | DNS validation records needed |

## Certificate Configuration

### Validation Method
- **DNS Validation**: Automatic validation via DNS records
- **Lifecycle Management**: Create before destroy for zero-downtime updates

### Domain Support
- **Primary Domain**: Main domain for the certificate
- **Subject Alternative Names**: Additional domains/subdomains
- **Wildcard Support**: Supports wildcard certificates (*.example.com)

## Example Usage

```hcl
module "acm" {
  source = "./modules/acm"

  domain_name               = "example.com"
  subject_alternative_names = ["www.example.com", "api.example.com"]
  app_name                  = "my-app"
  environment               = "production"
}
```

## Certificate Validation

**Important**: This module only creates the certificate. Validation is handled in `main.tf`:

1. **Route53 DNS Records**: Created for domain validation
2. **Certificate Validation**: Waits for DNS validation to complete
3. **HTTPS Listener**: Uses validated certificate

This separation prevents circular dependencies between Route53, ACM, and ALB modules.

## Dependencies

- **Domain Ownership**: Must own the domain being validated
- **Route53 Integration**: DNS validation requires Route53 hosted zone

## Security Features

- **Encryption in Transit**: TLS 1.2+ encryption
- **Automatic Renewal**: AWS handles certificate renewal
- **Domain Validation**: Proves domain ownership
- **Integration**: Works with ALB, CloudFront, API Gateway

## Best Practices

- Use DNS validation for automation
- Include www subdomain in SAN list
- Tag certificates for management
- Monitor certificate expiration
- Use wildcard certificates for multiple subdomains

## Common Configurations

### Single Domain
```hcl
domain_name               = "app.example.com"
subject_alternative_names = []
```

### Domain + WWW
```hcl
domain_name               = "example.com"
subject_alternative_names = ["www.example.com"]
```

### Wildcard Certificate
```hcl
domain_name               = "*.example.com"
subject_alternative_names = ["example.com"]
```

### Multiple Subdomains
```hcl
domain_name               = "example.com"
subject_alternative_names = [
  "www.example.com",
  "api.example.com",
  "admin.example.com"
]
```