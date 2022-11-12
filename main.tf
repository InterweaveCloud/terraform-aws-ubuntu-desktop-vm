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