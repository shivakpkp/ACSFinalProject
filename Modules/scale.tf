##finding ami id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 3.27"
    }
  }
  # required_version = "~> 1.1.5" # 1.1.5 or above and below 1.2.0
}
