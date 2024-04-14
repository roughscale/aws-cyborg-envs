module "vpc" {
  source                   = "../vpc"
  vpc_cidr                 = "192.168.10.0/24"
  env                      = "learn"
  domain                   = "learn.lan"
  aws_region               = var.region
}

resource "aws_subnet" "external" {
  vpc_id      = module.vpc.id
  cidr_block  = cidrsubnet(module.vpc.cidr_block,2,0)
  availability_zone = var.az

  tags = {
    Name = "Attacker"
  }
}

resource "aws_subnet" "internal" {
  count       = var.enable_agent ? 1 : 0
  vpc_id      = module.vpc.id
  cidr_block  = cidrsubnet(module.vpc.cidr_block,2,1)
  availability_zone = var.az

  tags = {
    Name = "${var.env}-internal"
  }
}

resource "aws_security_group" "ssh" {
  vpc_id      = module.vpc.id
  name        = "${var.env}-ssh"
  description = "ssh security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ module.vpc.cidr_block ]
  }

  tags = {
    Name = "${var.env}-ssh"
  }
}

resource "aws_security_group" "target_external" {
  count       = var.target_external_cidr_block != "" ? 1 : 0
  vpc_id      = module.vpc.id
  name        = "${var.env}-target-external"
  description = "target external security group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ var.target_external_cidr_block ]
  }

  tags = {
    Name = "${var.env}-target-external"
  }
}
