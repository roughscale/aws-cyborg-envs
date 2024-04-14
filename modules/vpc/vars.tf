## VPC

variable "vpc_cidr" {
  description = "VPC CIDRs"
}

variable "env" {
  description = "environment"
}

variable "domain" {}

variable "aws_region" {
  description = "Specifying a region"
}

variable "create_igw" { 
  default = true
}
