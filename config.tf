terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "terraform" { }

terraform {
  backend "s3" {
    bucket = "#BUCKET_NAME#"
    key    = "#CONTAINER_NAME#"
    region = "ap-southeast-2"
    encrypt = true
  }
}
