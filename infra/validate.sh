#!/bin/bash

# Terraform validation script for ECS webapp

echo "🔍 Validating Terraform configuration..."

# Check if required tools are installed
echo "Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed. Aborting." >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is required but not installed. Aborting." >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed. Aborting." >&2; exit 1; }

echo "✅ All prerequisites installed"

# Check AWS credentials
echo "Checking AWS credentials..."
aws sts get-caller-identity >/dev/null 2>&1 || { echo "❌ AWS credentials not configured. Run 'aws configure' first." >&2; exit 1; }
echo "✅ AWS credentials configured"

# Check if S3 bucket exists
BUCKET_NAME="ecs-webapp-terraform-state-sohaib"
echo "Checking if S3 bucket $BUCKET_NAME exists..."
if aws s3 ls "s3://$BUCKET_NAME" >/dev/null 2>&1; then
    echo "✅ S3 bucket exists"
else
    echo "⚠️  S3 bucket doesn't exist. Creating it..."
    aws s3 mb "s3://$BUCKET_NAME" --region us-east-1 || { echo "❌ Failed to create S3 bucket" >&2; exit 1; }
    
    # Enable versioning
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
    
    # Enable encryption
    aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
    
    echo "✅ S3 bucket created and configured"
fi

# Validate Terraform syntax
echo "Validating Terraform syntax..."
terraform fmt -check -recursive || { echo "❌ Terraform formatting issues found. Run 'terraform fmt -recursive' to fix." >&2; exit 1; }
echo "✅ Terraform formatting is correct"

terraform init -backend=false >/dev/null 2>&1 || { echo "❌ Terraform initialization failed" >&2; exit 1; }
terraform validate || { echo "❌ Terraform validation failed" >&2; exit 1; }
echo "✅ Terraform configuration is valid"

# Check if Docker daemon is running
echo "Checking Docker daemon..."
docker info >/dev/null 2>&1 || { echo "❌ Docker daemon is not running. Start Docker first." >&2; exit 1; }
echo "✅ Docker daemon is running"

echo ""
echo "🎉 All validations passed! Your Terraform configuration is ready for deployment."
echo ""
echo "Next steps:"
echo "1. terraform init"
echo "2. terraform plan"
echo "3. terraform apply"