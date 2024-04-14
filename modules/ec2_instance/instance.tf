resource "aws_instance" "instance" {
  ami           = var.ami
  count         = var.instance_count
  instance_type = var.instance_type

  subnet_id              = var.instance_subnet

  vpc_security_group_ids = length(var.instance_security_groups) > 0 ? var.instance_security_groups : null

  tags = {
    Name = var.instance_name
  }

  # the public SSH key
  key_name = var.bootstrap_user_public_key

  # launch time user data
  user_data_base64 = var.user_data_base64

  # source/dest check
  source_dest_check = var.source_dest_check

  iam_instance_profile = var.instance_profile_name
}
