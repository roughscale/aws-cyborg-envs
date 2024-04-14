resource "aws_vpc_dhcp_options" "main" {
  domain_name_servers = ["169.254.169.253"]
  domain_name         = "${var.env}.${var.domain}"

  tags = {
    Name = "${var.env}.${var.domain}"
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.env
  }
}

# zeroing default security group

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

# tag created publlc default route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-rt-public"
  }
}

resource "aws_route" "public" {
  count                     = var.create_igw ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw[count.index].id
}
  
# vpc internet gateway
resource "aws_internet_gateway" "igw" {
  count    = var.create_igw ? 1 : 0
  vpc_id   = aws_vpc.main.id
  # implicit dependency not working for resource deletion
  depends_on = [aws_vpc.main]
}
