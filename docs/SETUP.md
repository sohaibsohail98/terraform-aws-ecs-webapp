# 📋 Setup Guide

## What I Did First

### 1. Created Backend Infrastructure for Remote State Storage

**Why**: Terraform state files contain sensitive information and need to be shared across team members and CI/CD pipelines. Remote state storage provides consistency, security, and enables state locking.

**What I Created**:
- I created a S3 Bucket for the Terraform State
- Enabled versioning
- Enabled server-side encryption

**Backend Configuration**:
```hcl
# In provider.tf
backend "s3" {
  bucket         = "ecs-webapp-terraform-state-sohaib"
  key            = "terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  use_lockfile = true
}
```

This is crucial because it allows the new lock file functionality from Terraform in its latest update to lock the state file as default instead of relying on DynamoDB's state locking. This has only recently been updated in Terraform.

### 2. Created GitHub Actions Workflow for Terraform Plan

**Why**: Automated validation ensures code quality, security, and prevents configuration drift. The workflow validates Terraform syntax, formatting, and generates execution plans for review.

**Workflow Features**:
- **AWS Authentication**: Uses OIDC for secure, keyless AWS access
- **Security Scanning**: Using Checkov, Terratest and TF Lint (Temporarily commented out)
- **Terraform Validation**: Runs `terraform fmt`, `terraform validate`
- **Plan Generation**: Creates detailed execution plans for review
- **Security Scanning using TF**: Validates configurations against best practices
- **Multi-Environment Support**: Can be extended for dev/staging/prod

**Workflow Configuration** (`.github/workflows/terraform-plan.yml`):
```yaml
name: 'Terraform Plan'

on:
  pull_request:
    branches: [ main ]
    paths: [ 'terraform/**' ]

permissions:
  id-token: write   # Required for OIDC
  contents: read    # Required to checkout code
  pull-requests: write  # Required to comment on PRs

jobs:
  terraform-plan:
    name: 'Terraform Plan'
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsRole
        aws-region: us-east-1

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.9.0

    - name: Terraform Format Check
      working-directory: ./terraform
      run: terraform fmt -check -recursive

    - name: Terraform Init
      working-directory: ./terraform
      run: terraform init

    - name: Terraform Validate
      working-directory: ./terraform
      run: terraform validate

    - name: Terraform Plan
      working-directory: ./terraform
      run: terraform plan -var-file="terraform.tfvars" -out=tfplan

    - name: Comment PR
      uses: actions/github-script@v7
      with:
        script: |
          const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

          *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })
```

### 3. Created Terraform Infrastructure Code

**Why**: Infrastructure-as-code provides version control, repeatability, and documentation for cloud resources. The modular approach ensures maintainability and reusability across environments.

**Code Organization**:
```
terraform/
├── main.tf          # Networking and load balancer resources
├── ecs.tf           # ECS cluster, service, and task definitions
├── variables.tf     # Variable definitions (no defaults)
├── terraform.tfvars # Environment-specific configurations
├── provider.tf      # Provider and backend configuration
└── outputs.tf       # Output values for integration
```