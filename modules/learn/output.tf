output "internal_route_table_id" {
  value = one(aws_route_table.internal[*].id)
}

output "vpc_id" {
  value = module.vpc.id
}

output "vpc_cidr_block" {
  value = module.vpc.cidr_block
}

output "internal_cidr_block" {
  value = one(aws_subnet.internal[*].cidr_block)
}

output "external_cidr_block" {
  value = aws_subnet.external.cidr_block
}

output "external_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "gateway_interface_id" {
  value = one(module.controlserver[*].network_interface_id)
}

output "env" {
  value = var.env
}

output "controlserver_nic_id" {
  value = module.controlserver.primary_network_interface_id
}
