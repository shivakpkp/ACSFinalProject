output "vpc_id" {
  value = aws_vpc.aws_vpc_name.id
}

output "subnet_id" {
  value = aws_subnet.subnet_block[*]
}
output "aws_launch_configuration" {
  value = aws_launch_configuration.launchconfig
}

output "aws_autoscaling_group" {
  value = aws_autoscaling_group.scallingGroup
}

output "aws_eip" {
  value = aws_eip.eip
}