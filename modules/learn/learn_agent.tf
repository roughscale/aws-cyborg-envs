resource "aws_security_group" "agent" {
  count       = var.enable_agent ? 1 : 0
  vpc_id      = module.vpc.id
  name        = "${var.env}-agent"
  description = "${var.env}-agent"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [ aws_subnet.external.cidr_block ]
  }

  egress {
    description = "proxy-control"
    from_port   = 3128
    to_port     = 3128
    protocol    = "TCP"
    cidr_blocks = [ aws_subnet.external.cidr_block ]
  }

  dynamic "egress" {
    for_each = var.target_external_cidr_block != "" ? [1] : []
    content {
      description = "target-env"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [ var.target_external_cidr_block ]
    }
  }

  tags = {
    Name = "${var.env}-agent"
  }
}

module "agentserver" {
  count                     = var.enable_agent ? 1 : 0
  source                    = "../../ec2_instance"
  ami                       = var.agent_ami_id
  instance_type             = "t2.small"
  instance_vpc              = module.vpc.id
  instance_subnet           = aws_subnet.internal[count.index].id
  instance_name             = "agent.learn.lan"
  bootstrap_user_public_key = aws_key_pair.learn.key_name
  volume_size               = 12
}

resource "aws_route_table" "internal" {
  count  = var.enable_agent ? 1 : 0
  vpc_id = module.vpc.id
}

# attach route table to private subnet
resource "aws_route_table_association" "internal" {
  count    = var.enable_agent ? 1 : 0
  subnet_id = aws_subnet.internal[count.index].id
  route_table_id = aws_route_table.internal[count.index].id
}
