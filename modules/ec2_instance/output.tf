output "instance_id" {
  value = aws_instance.instance.*.id
}

output "network_interface_id" {
  value = one(aws_instance.instance[*].primary_network_interface_id)
}

output "primary_network_interface_id" {
  value = one(aws_instance.instance[*].primary_network_interface_id)
}
