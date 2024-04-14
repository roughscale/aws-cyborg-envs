variable "az" {}

variable "env" {}

variable "region" {}

variable "mgmt_cidrs" {
  type = list
}

variable "learn_external_cidr_block" {}
 
variable "target_windows_ami_id" {}
variable "target_gateway_ami_id" {}
variable "target_linux_ami_id" {}

variable "public_key_filename" {}

variable "pi_password" {}
variable "vagrant_password" {}
