variable "az" {}

variable "env"{
  default = "learn"
}

variable "mgmt_cidrs" {
  type = list
}

variable "region" { default = "ap-southeast-2" }

variable "target_external_cidr_block" {}

variable "agent_ami_id" {}
variable "control_ami_id" {}

variable "agent_instance_type" { default = "t2.small" }
variable "control_instance_type" { default = "t3.medium" }
variable "instance_type" { default = "t2.small" }

variable "enable_agent" { default = false }

variable "public_key_filename" {}

