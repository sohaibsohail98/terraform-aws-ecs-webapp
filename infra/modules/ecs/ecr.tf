# Use existing ECR Repository
data "aws_ecr_repository" "app_repo" {
  name = var.ecr_repository_name
}

data "aws_ecr_image" "app_image" {
  repository_name = data.aws_ecr_repository.app_repo.name
  image_tag       = var.image_tag # e.g. "latest" or your timestamp tag
}