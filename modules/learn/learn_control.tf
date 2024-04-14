resource "aws_security_group" "control" {
  vpc_id      = module.vpc.id
  name        = "${var.env}-control"
  description = "${var.env}-control"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.mgmt_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-control"
  }
}

resource "aws_key_pair" "learn" {
  key_name = "bootstrap@learn.lan"
  public_key = file(var.public_key_filename)
}

data "template_cloudinit_config" "control" {
  gzip          = true
  base64_encode = true

  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/control_cloudinit.tmpl",{})
  }
}

module "controlserver" {
  source                    = "../ec2_instance"
  ami                       = var.control_ami_id
  instance_type             = var.control_instance_type
  instance_vpc              = module.vpc.id
  instance_subnet           = aws_subnet.external.id
  instance_name             = "Attacker0"
  source_dest_check         = false # instance is a NAT gateway
  user_data_base64          = data.template_cloudinit_config.control.rendered
  bootstrap_user_public_key = aws_key_pair.learn.key_name
  volume_size               = 20
}

resource "aws_network_interface_sg_attachment" "control_control" {
  security_group_id    = aws_security_group.control.id
  network_interface_id = module.controlserver.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "control_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = module.controlserver.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "control_target_external" {
  count                = var.target_external_cidr_block != "" ? 1 : 0
  security_group_id    = aws_security_group.target_external[0].id
  network_interface_id = module.controlserver.primary_network_interface_id
}

# assign public IP to instance
resource "aws_eip" "control" {
  domain   = "vpc"
  instance = module.controlserver.instance_id[0]
}

# attach public route table to targetserver subnet
resource "aws_route_table_association" "external" {
  subnet_id = aws_subnet.external.id
  route_table_id = module.vpc.public_route_table_id
}

