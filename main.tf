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

// AMI-ID of Ubuntu Desktop 20.04 with Chrome RDP and KDE Plasma 5 -ami-0927aded7477e6e87
// Ubuntu 22.04 AMI - ami-0f540e9f488cfa27d 
// Public Ubuntu Desktop 22.04 AMI with Chrome RDP and KDE Plasma 5 - ami-0a00786fb4fbf6df7
resource "aws_spot_instance_request" "instance" {
  // Spot instance request configuration
  spot_price                     = "${var.instance_spot_price}"
  instance_type                  = "${var.instance_type}"
  instance_interruption_behavior = "${var.instance_interruption_behavior}"
  block_duration_minutes         = "${var.instance_block_duration_minutes}"

  // EC2 Configuration
  ami                         = "${var.instance_ami}"
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = module.vpc.public_subnets[0]
  monitoring                  = var.instance_monitoring
  key_name                    = aws_key_pair.instance_ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]

  // Use this code block to create a new AMI
  root_block_device {
    volume_size           = var.root_block_device_size
    volume_type           = "${var.root_block_device_type}"
    throughput            = var.root_block_device_throughput
    encrypted             = var.root_block_device_encryption
    delete_on_termination = var.root_block_device_delete_on_termination
  }

  tags = {
    Name = "UbuntuDesktop"
    AutomatedEbsBackups = "true"
  }
}

resource "aws_eip" "instance_ip" {
  vpc = true
}

resource "aws_eip_association" "instance_eip_assoc" {
  instance_id   = aws_spot_instance_request.instance.spot_instance_id
  allocation_id = aws_eip.instance_ip.id
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "${var.iam_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "${var.iam_role_policy_name}"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:DeleteSnapshot",
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}