vpc_id = "10.0.0.0/16"
subnets = {
  public1 = ["10.0.1.0/24"],
  public2 = ["10.0.2.0/24"],
  private1 = ["10.0.11.0/24"],
  private2 = ["10.0.12.0/24"]
}
aws_region = "us-east-1"