variable "ami" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_count" {
  default = 1
}

variable "encrypt_volume" {
  default = false
}

variable "instance_security_groups" { 
  type = list
  default = []
}

variable "instance_name" { }

variable "instance_subnet" { }

variable "instance_vpc" { }

variable "bootstrap_user_public_key" { }

variable "user_data_base64" {
  default = null
}

variable "source_dest_check" {
  default = true
}

variable "volume_size" {
  default = 0
}

#variable "volume_az" {}

variable "instance_profile_name" {
  default = null
}

