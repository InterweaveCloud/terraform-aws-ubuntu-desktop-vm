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

resource "aws_security_group" "instance_sg" {
  name        = "${var.instance_sg_name}"
  description = "Allows inbound SSH traffic from your IP address"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.user_ip_address}/32"]
  }

  ingress {
    description = "SSH from home IP"
    from_port   = 5901
    to_port     = 5901
    protocol    = "tcp"
    cidr_blocks = ["${var.user_ip_address}/32"]
  }

  ingress {
    description = "SSH from home IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.user_ip_address}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_inbound"
  }
}