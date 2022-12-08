locals { subnet_id = toset([aws_subnet.subnet_block["1"].id, aws_subnet.subnet_block["3"].id, aws_subnet.subnet_block["5"].id]) }

resource "aws_lb_target_group" "target_group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    
  }

  name        = "terraformlovers"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.aws_vpc_name.id
}

resource "aws_lb" "application_lb" {
  name               = "tl-lb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_security_group.id]
  subnets            = local.subnet_id

  tags = {
    Name = "tl_lb"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}

# resource "aws_lb_target_group_attachment" "ec2_attachment" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id        = aws_launch_configuration.launchconfig.id
#   port             = 80
# }

# resource "aws_elb" "tl_lb" {
#   name            = "tlelb"
#   subnets         = local.subnet_id
#   security_groups = [aws_security_group.elb_security_group.id]
#   listener {
#     instance_port     = 80
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }
#   health_check {
#     interval            = 10
#     target                = "http:80/"
#     timeout             = 5
#     healthy_threshold   = 5
#     unhealthy_threshold = 2
#   }

#   cross_zone_load_balancing   = true
#   connection_draining         = true
#   connection_draining_timeout = 400

#   tags = {
#     Name = "tl_elb"
#   }
# }
