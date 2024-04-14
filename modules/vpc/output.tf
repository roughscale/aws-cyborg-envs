output "id" {
  value = aws_vpc.main.id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "name" {
  value = aws_vpc.main.tags.Name
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "igw_id" {
  value = one(aws_internet_gateway.igw[*].id)
}
