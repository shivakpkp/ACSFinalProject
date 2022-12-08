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

# ssh-key
resource "aws_key_pair" "vm_key" {
  key_name   = var.vmprefix
  public_key = file("${var.keyName}.pub")
}


# auto scalling configuration
resource "aws_launch_configuration" "launchconfig" {
  name            = "autoscale_config"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = lookup(var.instanceType, var.env, "dev")
  key_name        = aws_key_pair.vm_key.key_name
  security_groups = [aws_security_group.vm_security_group.id]
  user_data       = file("${path.module}/install_httpd.sh")

  lifecycle {
    create_before_destroy = true
  }
  
}
