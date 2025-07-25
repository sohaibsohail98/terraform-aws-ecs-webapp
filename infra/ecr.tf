# ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.app_name}-ecr"
    Environment = var.environment
  }
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
      }
    ]
  })
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Docker build and push using null_resource
resource "null_resource" "docker_build_push" {
  triggers = {
    # Trigger rebuild when these files change
    dockerfile_hash = filemd5("${path.module}/../Dockerfile")
    app_py_hash     = filemd5("${path.module}/../app.py")
    requirements_hash = filemd5("${path.module}/../requirements.txt")
    # Force rebuild when ECR repository changes
    ecr_repository_url = aws_ecr_repository.app.repository_url
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Navigate to the application directory
      cd ${path.module}/..

      # Get ECR login token
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}

      # Build the Docker image
      docker build -t ${var.app_name}:latest .

      # Tag the image for ECR
      docker tag ${var.app_name}:latest ${aws_ecr_repository.app.repository_url}:latest
      docker tag ${var.app_name}:latest ${aws_ecr_repository.app.repository_url}:${formatdate("YYYY-MM-DD-hhmm", timestamp())}

      # Push both tags to ECR
      docker push ${aws_ecr_repository.app.repository_url}:latest
      docker push ${aws_ecr_repository.app.repository_url}:${formatdate("YYYY-MM-DD-hhmm", timestamp())}
    EOT
  }

  depends_on = [aws_ecr_repository.app]
}

# Local variable for ECR image URL
locals {
  ecr_image_url = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
}