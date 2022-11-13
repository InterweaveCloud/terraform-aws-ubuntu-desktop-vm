// Define Local Vars

locals {
  tags = {
    Terraform   = "${var.terraform_tag}"
    Environment = "${var.environment}"
  }
}

data "aws_region" "current" {}

// VPC Configuration

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>3.18.1"

  name = "${var.prefix}-spot-instance-vpc-${var.environment}"
  cidr = var.use_ipam_pool ? null : var.vpc_cidr_block

  azs            = ["${data.aws_region.current.name}a", ]
  public_subnets = [var.public_subnet_cidr_block, ]

  tags = local.tags
}

// Instance Configuration

resource "aws_key_pair" "instance_ssh_key" {
  key_name   = "${module.vpc.name}-ssh-key-pair"
  public_key = var.public_key
}

resource "aws_security_group" "instance_sg" {
  name        = "${module.vpc.name}instance_security_group"
  description = "Allows inbound SSH traffic from specified IP addresses. Reccomended to be limited to your personal IP address."
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from specified IP addresses. Reccomended to be limited to your personal IP address."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  ingress {
    description = "SSH from specified IP addresses. Reccomended to be limited to your personal IP address."
    from_port   = 5901
    to_port     = 5901
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  ingress {
    description = "SSH from specified IP addresses. Reccomended to be limited to your personal IP address."
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.allowed_ingress_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

resource "aws_spot_instance_request" "instance" {
  // Spot instance request configuration
  spot_price                     = var.instance_spot_price
  instance_type                  = var.instance_type
  instance_interruption_behavior = var.instance_interruption_behavior
  block_duration_minutes         = var.instance_block_duration_minutes

  // EC2 Configuration
  ami                         = var.instance_ami
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = module.vpc.public_subnets[0]
  monitoring                  = var.instance_monitoring
  key_name                    = aws_key_pair.instance_ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]

  // Use this code block to create a new AMI
  root_block_device {
    volume_size           = var.root_block_device_size
    volume_type           = var.root_block_device_type
    throughput            = var.root_block_device_throughput
    encrypted             = var.root_block_device_encryption
    delete_on_termination = var.root_block_device_delete_on_termination
  }

  tags = merge(
    local.tags,
    {
    Name                = "UbuntuDesktop"
    AutomatedEbsBackups = "true"
  },
  )
}

resource "aws_eip" "instance_ip" {
  vpc = true
}

resource "aws_eip_association" "instance_eip_assoc" {
  instance_id   = aws_spot_instance_request.instance.spot_instance_id
  allocation_id = aws_eip.instance_ip.id
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm-lifecycle-role"

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
  name = "${aws_iam_role.dlm_lifecycle_role.name}-policy"
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

resource "aws_dlm_lifecycle_policy" "instance_backup" {
  description        = "Backup instance daily right before midnight and retain for 1 week"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      AutomatedEbsBackups = "true"
    }
  }
}