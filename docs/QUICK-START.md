# 🚀 Quick Start Guide

## Prerequisites
- Terraform >= 1.10
- AWS CLI configured with appropriate permissions
- Docker for building container images

## Deployment Steps

### 1. Clone and Configure

```bash
git clone <your-repo>
cd terraform/
```

### 2. Configure Variables

Edit `terraform.tfvars` and provide values for all required variables:

```hcl
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

aws_region         = "us-east-1"
container_port     = 5000
health_check_path  = "/health"
app_name          = "sohaib-portfolio"
environment       = "dev"

# ECS Configuration
container_image = "your-account.dkr.ecr.us-east-1.amazonaws.com/sohaib-portfolio:latest"
cpu            = 256
memory         = 512
desired_count  = 2
min_capacity   = 1
max_capacity   = 10
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Apply

```bash
terraform plan
terraform apply
```

### 5. Access Your Application

After deployment, your application will be available at the load balancer URL shown in the outputs:

```bash
terraform output load_balancer_url
```

## Application Deployment

### Local Development
```bash
# Local development
export FLASK_SECRET_KEY=$(python -c "import secrets; print(secrets.token_hex(32))")
pip install -r requirements.txt
python app.py
# Visit: http://localhost:5000 (Portfolio) | http://localhost:5000/game (Snake Game)
```

### Docker Deployment
```bash
# Docker deployment
docker build -t sohaib-portfolio .
docker run -p 5000:5000 -e FLASK_SECRET_KEY=your_secret_key sohaib-portfolio
```

## ECS Deployment Compatibility
The application maintains full compatibility with the existing Terraform ECS infrastructure:
- **Port**: Still uses port 5000 (matches ECS configuration)
- **Health Check**: `/health` endpoint (matches ALB target group)
- **Container**: Same Dockerfile structure with gunicorn
- **Environment**: Flask secret key configurable via environment variables