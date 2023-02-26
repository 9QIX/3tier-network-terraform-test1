data "aws_availability_zones" "available" {
}

data "aws_region" "current" {}

# Define VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_key_pair" "pukey" {
  key_name = "pukey"
}

variable "private_subnets" {
  default = {
    "tier2_sg"  = 250
  }
}