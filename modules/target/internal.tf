resource "aws_security_group" "internal" {
  vpc_id      = module.vpc.id
  name        = "${var.env}-internal"
  description = "${var.env}-internal"

  ingress {
    description = "All from learning agent"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ var.learn_external_cidr_block ]
  }

  
  ingress {
    description = "All from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ module.vpc.cidr_block ]
  }

  ingress {
    description = "All from VPC secondary CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ aws_vpc_ipv4_cidr_block_association.internal.cidr_block ]
  }

  egress {
    description = "All to all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.env}-internal"
  }
}

resource "aws_security_group" "internal_public" {
  vpc_id      = module.vpc.id
  name        = "${var.env}-internal-public"
  description = "${var.env}-internal-public"

  egress {
    description = "Outbound Public"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.env}-internal-public"
  }
}

module "internal0_linux_host" {
  source                    = "../ec2_instance"
  ami                       = var.target_linux_ami_id
  instance_vpc              = module.vpc.id
  instance_type             = "t2.medium"
  instance_subnet           = aws_subnet.internal.id
  instance_name             = "Internal0"
  #instance_security_groups  = [ aws_security_group.internal.id, aws_security_group.internal_public.id ]
  bootstrap_user_public_key = aws_key_pair.target.key_name
  volume_size               = 0
  user_data_base64          = data.template_cloudinit_config.internal0.rendered
}

resource "aws_network_interface_sg_attachment" "internal0_internal" {
  security_group_id    = aws_security_group.internal.id
  network_interface_id = module.internal0_linux_host.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "internal0_internal_public" {
  security_group_id    = aws_security_group.internal_public.id
  network_interface_id = module.internal0_linux_host.primary_network_interface_id
}

module "internal1_linux_host" {
  source                    = "../ec2_instance"
  ami                       = var.target_windows_ami_id
  instance_vpc              = module.vpc.id
  instance_type             = "t2.medium"
  instance_subnet           = aws_subnet.internal.id
  instance_name             = "Internal1"
  #instance_security_groups  = [ aws_security_group.internal.id, aws_security_group.internal_public.id ]
  bootstrap_user_public_key = aws_key_pair.target.key_name
  volume_size               = 0
  user_data_base64          = data.template_cloudinit_config.internal1.rendered
}

resource "aws_network_interface_sg_attachment" "internal1_internal" {
  security_group_id    = aws_security_group.internal.id
  network_interface_id = module.internal1_linux_host.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "internal1_internal_public" {
  security_group_id    = aws_security_group.internal_public.id
  network_interface_id = module.internal1_linux_host.primary_network_interface_id
}

module "internal2_linux_host" {
  source                    = "../ec2_instance"
  ami                       = var.target_linux_ami_id
  instance_vpc              = module.vpc.id
  instance_type             = "t2.medium"
  instance_subnet           = aws_subnet.internal.id
  instance_name             = "Internal2"
  #instance_security_groups  = [ aws_security_group.internal.id, aws_security_group.internal_public.id ]
  bootstrap_user_public_key = aws_key_pair.target.key_name
  volume_size               = 0
  user_data_base64          = data.template_cloudinit_config.internal2.rendered
}

resource "aws_network_interface_sg_attachment" "internals2_internal" {
  security_group_id    = aws_security_group.internal.id
  network_interface_id = module.internal2_linux_host.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "internal2_internal_public" {
  security_group_id    = aws_security_group.internal_public.id
  network_interface_id = module.internal2_linux_host.primary_network_interface_id
}

# set up vpc route for internal subnet
resource "aws_route_table" "internal" {
  vpc_id = module.vpc.id

  tags = {
    Name = "${var.env}-rt-internal"
  }
}

resource "aws_route" "internal_agent" {
  route_table_id            = aws_route_table.internal.id
  destination_cidr_block    = var.learn_external_cidr_block
  network_interface_id      = aws_network_interface.external_internal.id
}

# attach route table to internal subnet
resource "aws_route_table_association" "internal" {
  subnet_id = aws_subnet.internal.id
  route_table_id = aws_route_table.internal.id
}
