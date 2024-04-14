output "external_route_table_id" {
  value = aws_route_table.external.id
}

output "vpc_id" {
  value = module.vpc.id
}

output "vpc_cidr_block" {
  value = module.vpc.cidr_block
}

output "external_cidr_block" {
  value = aws_subnet.external.cidr_block
}

output "internal_cidr_block" {
  value = aws_subnet.internal.cidr_block
}

output "internal_route_table_id" {
  value = aws_route_table.internal.id
}

output "internet_gateway_id" {
  value = module.vpc.igw_id
}

#output "nat_gateway_id" {
#  value = aws_nat_gateway.external.id
#}

output "env" {
  value = var.env
}
