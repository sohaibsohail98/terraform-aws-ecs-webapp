# ECR Repository Policy
resource "aws_ecr_repository_policy" "app" {
  repository = data.aws_ecr_image.app_image.repository_name

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
  repository = data.aws_ecr_image.app_image.repository_name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

data "aws_ecr_image" "app_image" {
  repository_name = var.ecr_repository_name
  image_tag       = var.image_tag # e.g. "latest" or your timestamp tag
}