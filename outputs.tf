output "vpc_id" {
  description = "The ID of the VPC"
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The arn of the VPC"
  value = module.vpc.vpc_arn
}

output "public_subnet_id" {
  description = "The public subnet ID"
  value = module.vpc.public_subnets
}

output "public_subnet_arn" {
  description = "The public subnet arn"
  value = module.vpc.public_subnet_arns
}

output "public_subnet_cidr_block" {
  description = "The public subnet CIDR block"
  value = module.vpc.public_subnets_cidr_blocks
}

output "instance_ssh_key_arn" {
  description = "The arn of the instance ssh key pair"
  value = aws_key_pair.instance_ssh_key.arn
}

output "instance_ssh_key_id" {
  description = "The ID of the instance ssh key pair"
  value = aws_key_pair.instance_ssh_key.id
}

output "instance_sg_arn" {
  description = "The arn of the instance security group"
  value = aws_security_group.instance_sg.arn
}

output "instance_sg_id" {
  description = "The ID of the instance security group"
  value = aws_security_group.instance_sg.id
}