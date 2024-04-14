resource "random_integer" "target_env_external" {
  min = 0
  max = 255
}

resource "random_integer" "target_env_internal" {
  min = 0
  max = 255
}

locals {
  # ensure random environment doesn't clash with static attacker env
  external_env = random_integer.target_env_external.result == 10 ? 11 : random_integer.target_env_external.result
  internal_env = random_integer.target_env_internal.result == 10 ? 9 : random_integer.target_env_internal.result
}

module "vpc" {
  source                   = "../vpc"
  vpc_cidr                 = "192.168.${local.external_env}.0/24"
  env                      = var.env
  domain                   = "target.lan"
  aws_region               = var.region
  create_igw               = false
}

resource "aws_vpc_ipv4_cidr_block_association" "internal" {
  vpc_id      = module.vpc.id
  cidr_block  = "192.168.${local.internal_env}.0/24"
}

resource "aws_subnet" "external" {
  vpc_id      = module.vpc.id
  cidr_block  = cidrsubnet(module.vpc.cidr_block,4,9)
  availability_zone = var.az

  tags = {
    Name = "External"
  }
}

resource "aws_subnet" "internal" {
  vpc_id      = module.vpc.id
  cidr_block  = cidrsubnet(aws_vpc_ipv4_cidr_block_association.internal.cidr_block,4,0)
  availability_zone = var.az

  tags = {
    Name = "Internal"
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
    cidr_blocks = var.mgmt_cidrs
  }

  tags = {
    Name = "${var.env}-ssh"
  }
}

resource "aws_key_pair" "target" {
  key_name = "bootstrap@target.lan"
  public_key = file(var.public_key_filename)
}
