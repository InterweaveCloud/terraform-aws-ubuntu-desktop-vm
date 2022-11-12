// Define Local Vars

locals {
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_region" "current" {}

// VPC Configuration

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>3.18.1"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_CIDR_block}"

  azs            = ["${data.aws_region.current.name}a", ]
  public_subnets = ["${var.public_subnet_CIDR_block}", ]

  tags = local.tags
}

// Instance Configuration

resource "aws_key_pair" "instance_ssh_key" {
  key_name   = "${var.instance_ssh_key_pair_name}"
  public_key = file("instance-ssh-key.pub")
}