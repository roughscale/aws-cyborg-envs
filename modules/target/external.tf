resource "aws_security_group" "external" {
  vpc_id      = module.vpc.id
  name        = "${var.env}-external"
  description = "${var.env}-external"

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

  egress {
    description = "All to learning agent"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ var.learn_external_cidr_block ]
  }

  egress {
    description = "All to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ module.vpc.cidr_block ]
  }

  tags = {
    Name = "${var.env}-external"
  }
}

resource "aws_security_group" "external_public" {
  vpc_id      = module.vpc.id
  name        = "${var.env}-external-public"
  description = "${var.env}-external-public"

  egress {
    description = "Outbound Public"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.env}-external-public"
  }
}

resource "aws_instance" "external_host" {
  ami           = var.target_gateway_ami_id
  instance_type = "t2.medium"

  tags = {
    Name = "External0"
  }

  network_interface {
    network_interface_id = aws_network_interface.external_primary.id 
    device_index = 0
  }
  
  # the public SSH key
  key_name = aws_key_pair.target.key_name

  user_data_base64          = data.template_cloudinit_config.external0.rendered
}

resource "aws_network_interface" "external_primary" {
  subnet_id       = aws_subnet.external.id

  # source/dest check
  source_dest_check = false
}

resource "aws_network_interface" "external_internal" {
  subnet_id       = aws_subnet.internal.id
  source_dest_check = false

  attachment {
    instance     = aws_instance.external_host.id
    device_index = 1
  }
}

resource "aws_network_interface_sg_attachment" "external0_external" {
  security_group_id    = aws_security_group.external.id
  network_interface_id = aws_network_interface.external_primary.id
}

resource "aws_network_interface_sg_attachment" "external0_external_public" {
  security_group_id    = aws_security_group.external_public.id
  network_interface_id = aws_network_interface.external_primary.id
}

resource "aws_network_interface_sg_attachment" "external0_internal" {
  security_group_id    = aws_security_group.internal.id
  network_interface_id = aws_network_interface.external_internal.id
}

# set up vpc route for public subnet
resource "aws_route_table" "external" {
  vpc_id = module.vpc.id

  tags = {
    Name = "${var.env}-rt-external"
  }
}

# attach route table to learn_external subnet
resource "aws_route_table_association" "external" {
  subnet_id = aws_subnet.external.id
  route_table_id = aws_route_table.external.id
}
