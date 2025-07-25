resource "aws_vpc" "main" {
  cidr_block = var.vpc_id
}

resource "aws_subnet" "main" {
  for_each = var.subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value

  tags = {
    Name = "ecs-webapp-subnet-${each.key}"
  }
}