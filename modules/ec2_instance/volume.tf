locals {
  volume_count = var.volume_size ==0  ? 0 : var.instance_count
}

resource "aws_kms_key" "volume_key" {
  count                   = var.encrypt_volume ? 1: 0
  description = "volume_key"
  deletion_window_in_days = 7
  policy = data.aws_iam_policy_document.deploy-user-kms-usage.json
}

resource "aws_ebs_volume" "volume" {
  count             = local.volume_count
  availability_zone = data.aws_subnet.instance.availability_zone
  size              = var.volume_size
  encrypted         = var.encrypt_volume
  kms_key_id        = var.encrypt_volume ? aws_kms_key.volume_key[count.index].arn : null
}

#output "id" {
#  value = aws_ebs_volume.volume.id
#}

#module "volume_storage" {
#  source = "../ec2_volume"
#  volume_size = "12"
#  volume_az   = data.aws_subnet.instance.availability_zone
#}

resource "aws_volume_attachment" "attachment" {
  count       = local.volume_count
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.volume[count.index].id
  instance_id = aws_instance.instance[count.index].id
}
