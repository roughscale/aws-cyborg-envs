variable "deploy_learn" { default = true }
variable "deploy_target" { default = true }
variable "enable_agent" { default = false }

variable "mgmt_cidrs" {
  type = list
}

variable "region" { default = "ap-southeast-2" }

variable "agent_ami_id" {}
variable "control_ami_id" {}
variable "target_gateway_ami_id" {}
variable "target_linux_ami_id" {}
variable "target_windows_ami_id" {}

variable "agent_instance_type" { default = "t2.small" }
variable "control_instance_type" { default = "g3s.xlarge" }

variable "target_public_key_filename" {}
variable "learn_public_key_filename" {}

