resource "aws_instance" "BASTION" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = lookup(var.instanceType, var.env)
  subnet_id              = aws_subnet.subnet_block["3"].id
  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  key_name               = aws_key_pair.vm_key.key_name
  availability_zone      = aws_subnet.subnet_block["3"].availability_zone
  tags = {
    Name = "Bastion Host"
  }
}
