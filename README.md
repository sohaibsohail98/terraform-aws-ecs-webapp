# Sohaib Sohail - DevOps Portfolio Application

## 🎯 Current Application

This repository showcases a **professional portfolio web application** for **Sohaib Sohail**, DevOps Engineer at PwC, featuring:

### 👨‍💻 Portfolio Features
- **Professional Profile**: Showcasing 4+ years of cloud engineering experience at PwC and Capgemini
- **Technical Skills Display**: AWS, Azure, Terraform, CI/CD, DevSecOps expertise
- **Certifications**: Terraform Associate, Azure Fundamentals, AWS Cloud Practitioner  
- **Interactive Snake Game**: DevOps-themed educational game with professional branding
- **Modern Responsive Design**: Clean, professional interface suitable for demonstrations

### 🐳 Application Stack
- **Backend**: Flask (Python) with RESTful API endpoints
- **Frontend**: Modern CSS with responsive design
- **Container**: Production-ready Docker configuration
- **Health Monitoring**: `/health` endpoint for ECS health checks
- **Game API**: Score tracking and management endpoints

### 📸 Application Demo

#### Portfolio Homepage
![Portfolio Homepage](docs/images/portfolio-homepage.png)

#### Interactive Snake Game
![Snake Game](docs/images/snake-game.png)

## 🏗️ Infrastructure Overview

A production-ready, highly available ECS Fargate web application infrastructure deployed on AWS using Terraform. Features modular design, auto-scaling, comprehensive monitoring, and security-first architecture.

### Architecture Diagram
![ECS Architecture](docs/images/ecs-architecture.jpeg)

### 📁 Project Structure
```
├── app.py                 # Main Flask application (Portfolio & Game)
├── requirements.txt       # Python dependencies
├── Dockerfile            # Production-ready container
├── templates/
│   ├── home.html         # Professional portfolio homepage
│   └── game.html         # Interactive Snake game
├── dvla_archive/         # Original DVLA application (Archived)
└── infra/               # Terraform infrastructure (MODULARIZED)
    ├── modules/         # Reusable infrastructure modules
    │   ├── vpc/         # VPC, subnets, networking
    │   ├── alb/         # Application Load Balancer
    │   ├── security/    # Security groups
    │   ├── ecs/         # ECS cluster and services
    │   ├── acm/         # SSL certificates
    │   └── route53/     # DNS and domain management
    ├── main.tf          # Module orchestration
    ├── ARCHITECTURE.md  # Infrastructure architecture guide
    ├── DEPLOYMENT.md    # Deployment instructions
    └── VARIABLES.md     # Variable reference
```

## 🔧 Recent Infrastructure Improvements

### Infrastructure Modularization & Dependency Resolution (Latest Update)

The Terraform infrastructure has been **completely refactored** to eliminate circular dependencies and implement best practices:

#### ✅ Critical Fixes Applied
1. **Circular Dependency Resolution**:
   - Removed interdependent resource references between modules
   - Moved cross-module associations to main.tf
   - Implemented clean separation of concerns

2. **Certificate Validation Issues Fixed**:
   - Proper DNS validation workflow: Route53 → ACM → Certificate Validation → HTTPS Listener
   - Certificate validation now completes before ALB attempts to use it
   - Target group associations wait for validated certificates

3. **Modular Architecture Implemented**:
   - `modules/vpc/` - VPC, subnets, NAT gateways, route tables
   - `modules/alb/` - Application Load Balancer and target groups (HTTP only)
   - `modules/security/` - Security groups for ALB and ECS tasks
   - `modules/ecs/` - ECS cluster, service, task definitions, auto-scaling, ECR
   - `modules/acm/` - SSL certificate creation only
   - `modules/route53/` - Hosted zone creation only
   - `main.tf` - Handles all cross-module associations (HTTPS listener, DNS records, certificate validation)

4. **Code Quality Improvements**:
   - Removed all default values from module variables
   - Eliminated conditional logic complexity
   - Clean, predictable module behavior

#### 🎯 Benefits
- **No More Circular Dependencies**: Clean dependency graph with proper resource ordering
- **Reliable SSL/HTTPS**: Certificate validation completes before listener creation
- **Modular Design**: Each module has single responsibility, associations handled centrally
- **Maintainable Code**: No default values, explicit variable requirements
- **Production Ready**: Eliminates deployment failures from dependency conflicts

## 🚀 Quick Start

### Local Development
```bash
# Clone and setup
git clone <repo-url>
cd terraform-aws-ecs-webapp

# Local development
export FLASK_SECRET_KEY=$(python -c "import secrets; print(secrets.token_hex(32))")
pip install -r requirements.txt
python app.py
# Visit: http://localhost:5000
```

### Infrastructure Deployment
```bash
# Navigate to infrastructure
cd infra/

# Configure variables (edit terraform.tfvars)
# Initialize and deploy
terraform init
terraform plan
terraform apply
```

## 📚 Documentation

Comprehensive documentation has been split into focused guides:

| Document | Description |
|----------|-------------|
| [🚀 Quick Start](docs/QUICK-START.md) | Fast deployment guide |
| [🏗️ Infrastructure](docs/INFRASTRUCTURE.md) | Detailed AWS components |
| [🔧 Configuration](docs/CONFIGURATION.md) | Variable reference and setup |
| [🔧 Setup Guide](docs/SETUP.md) | Backend setup and CI/CD |
| [🔍 Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions |
| [🔒 Security](docs/SECURITY.md) | Security features and best practices |
| [🏗️ Architecture](infra/ARCHITECTURE.md) | Module structure and dependencies |
| [🚀 Deployment](infra/DEPLOYMENT.md) | Infrastructure deployment guide |
| [📝 Variables](infra/VARIABLES.md) | Complete variable reference |

## 🌟 Key Features

### Infrastructure Highlights
- **AWS ECS Fargate**: Serverless container orchestration
- **Application Load Balancer**: High availability and traffic distribution
- **Multi-AZ Deployment**: Across public and private subnets
- **Auto-scaling**: Based on CPU and memory utilization
- **Comprehensive Monitoring**: CloudWatch and Container Insights
- **Security-first Architecture**: Least privilege access

### DevOps Best Practices
- **Infrastructure as Code**: Terraform with modular design
- **CI/CD Integration**: GitHub Actions workflow
- **Remote State Management**: S3 backend with encryption
- **Security Scanning**: Automated security validation
- **Comprehensive Documentation**: Split into focused guides

## 🔒 Security Features

- **Network Isolation**: ECS tasks in private subnets
- **Security Groups**: Least privilege access
- **IAM Roles**: Minimal permissions
- **Encryption**: State files and data at rest
- **Monitoring**: CloudWatch logs and metrics

## 📊 Monitoring & Scaling

- **Auto Scaling**: CPU and memory-based policies
- **CloudWatch**: Comprehensive logging and monitoring
- **Health Checks**: ALB and container-level monitoring
- **Container Insights**: Enhanced ECS metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request with detailed description
5. Ensure all CI checks pass

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: This is a portfolio project demonstrating professional DevOps and cloud engineering capabilities. The infrastructure showcases production-ready patterns suitable for enterprise environments.