###-----------------locals---------------------###

locals { vm_subnets = { "1" : "${aws_subnet.subnet_block["2"].id}", "2" : "${aws_subnet.subnet_block["4"].id}", "3" : "${aws_subnet.subnet_block["6"].id}" } }
locals { gw_subnets = { "1" : "${aws_subnet.subnet_block["1"].id}", "2" : "${aws_subnet.subnet_block["3"].id}" ,"3" : "${aws_subnet.subnet_block["5"].id}"} }

###Route###
resource "aws_route_table" "route_table_gw" {
  vpc_id = aws_vpc.aws_vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table" "route_table_nat" {
  vpc_id = aws_vpc.aws_vpc_name.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

}

####Association###

resource "aws_route_table_association" "bastion_route_associate" {
  for_each       = local.gw_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.route_table_gw.id
}

# resource "aws_route_table_association" "Nat_route_associate" {
#   subnet_id      = aws_subnet.subnet_block["1"].id
#   route_table_id = aws_route_table.route_table_gw.id
# }

resource "aws_route_table_association" "Vm_route_associate" {
  for_each       = local.vm_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.route_table_nat.id
}
