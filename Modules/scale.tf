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


# autoscale_group
resource "aws_autoscaling_group" "scallingGroup" {
  name                      = "scal_group"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.launchconfig.name
  target_group_arns         = [aws_lb_target_group.target_group.arn]
  # availability_zones        = [
  # aws_subnet.subnet_block["2"].availability_zone,
  # aws_subnet.subnet_block["4"].availability_zone,
  # aws_subnet.subnet_block["6"].availability_zone]
  vpc_zone_identifier = [
    "${aws_subnet.subnet_block["2"].id}",
    "${aws_subnet.subnet_block["4"].id}",
  "${aws_subnet.subnet_block["4"].id}"]
  
  tag {
    key = "Name"
    value = "ec2_scale"
    propagate_at_launch = true
  }
}


# autoscale_policy

resource "aws_autoscaling_policy" "auto_policy" {
  name                   = "Scale_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.scallingGroup.name
}

# autoscale cloud watch

resource "aws_cloudwatch_metric_alarm" "custome_cpu_alarm" {
  alarm_name = "cpu_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 60
  statistic = "Average"
  threshold = 20
  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.scallingGroup.name
  }
  actions_enabled = true
  
  alarm_actions = [aws_autoscaling_policy.auto_policy.arn]
}

