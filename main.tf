# deploy learning vpc 
module "learn" {
  count  = var.deploy_learn ? 1 : 0
  source = "./modules/learn"
  az     = data.aws_availability_zones.available.names[0]
  env    = "learn"
  region = "ap-southeast-2"
  control_instance_type = var.control_instance_type
  control_ami_id = var.control_ami_id 
  agent_ami_id   = var.agent_ami_id
  target_external_cidr_block = ""
  public_key_filename = var.learn_public_key_filename
  mgmt_cidrs = var.mgmt_cidrs
}

module "target" {
  count  = var.deploy_target ? 1 : 0
  source = "./modules/target"
  az     = data.aws_availability_zones.available.names[0]
  env    = "target"
  region = "ap-southeast-2"
  target_gateway_ami_id = var.target_gateway_ami_id
  target_windows_ami_id = var.target_windows_ami_id
  target_linux_ami_id = var.target_linux_ami_id
  learn_external_cidr_block = var.deploy_learn ? module.learn[count.index].external_cidr_block : null
  public_key_filename = var.target_public_key_filename
  mgmt_cidrs = var.mgmt_cidrs
}

# add the security group rule to the control server after the target network has been deployed
resource "aws_security_group" "target_external" {
  count       = var.deploy_target && var.deploy_learn ? 1 : 0
  vpc_id      = module.learn[count.index].vpc_id
  name        = "${module.learn[count.index].env}-target-external"
  description = "target external security group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ module.target[count.index].external_cidr_block ]
  }

  tags = {
    Name = "${module.learn[count.index].env}-target-external"
  }
}

resource "aws_network_interface_sg_attachment" "control_target_external" {
  count                = var.deploy_learn && var.deploy_target ? 1 : 0
  security_group_id    = aws_security_group.target_external[count.index].id
  network_interface_id = module.learn[count.index].controlserver_nic_id
}

# peer learning and target vpcs
resource "aws_vpc_peering_connection" "learn_target" {
  count         = var.deploy_learn && var.deploy_target ? 1 : 0
  peer_vpc_id   = module.target[count.index].vpc_id
  vpc_id        = module.learn[count.index].vpc_id
  auto_accept   = true

  tags = {
    Name = "Peering between learning and target vpcs"
  }
}

resource "aws_route" "external_learn_external_target" {
  count                     = var.deploy_learn && var.deploy_target ? 1 : 0
  route_table_id            = module.learn[count.index].external_route_table_id
  destination_cidr_block    = module.target[count.index].external_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.learn_target[count.index].id
}

resource "aws_route" "external_target_external_learn" {
  count                     = var.deploy_learn && var.deploy_target ? 1 : 0
  route_table_id            = module.target[count.index].external_route_table_id
  destination_cidr_block    = module.learn[count.index].external_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.learn_target[count.index].id
}
