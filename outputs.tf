output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The arn of the VPC"
  value       = module.vpc.vpc_arn
}

output "public_subnet_id" {
  description = "The public subnet ID"
  value       = module.vpc.public_subnets
}

output "public_subnet_arn" {
  description = "The public subnet arn"
  value       = module.vpc.public_subnet_arns
}

output "public_subnet_cidr_block" {
  description = "The public subnet CIDR block"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "instance_ssh_key_arn" {
  description = "The arn of the instance ssh key pair"
  value       = aws_key_pair.instance_ssh_key.arn
}

output "instance_ssh_key_id" {
  description = "The ID of the instance ssh key pair"
  value       = aws_key_pair.instance_ssh_key.id
}

output "instance_sg_arn" {
  description = "The arn of the instance security group"
  value       = aws_security_group.instance_sg.arn
}

output "instance_sg_id" {
  description = "The ID of the instance security group"
  value       = aws_security_group.instance_sg.id
}

output "instance_arn" {
  description = "The arn of the instance"
  value       = aws_spot_instance_request.instance.arn
}

output "instance_id" {
  description = "The ID of the instance"
  value       = aws_spot_instance_request.instance.id
}

output "instance_public_ip" {
  description = "The public ip address of the instance"
  value       = aws_spot_instance_request.instance.public_ip
}

output "instance_private_ip" {
  description = "The private ip address of the instance"
  value       = aws_spot_instance_request.instance.private_ip
}

output "elastic_ip_id" {
  description = "The ID of the elastic IP"
  value       = aws_eip.instance_ip.id
}

output "lifecycle_policy_arn" {
  description = "The arn of the lifecycle policy"
  value       = aws_dlm_lifecycle_policy.instance_backup.arn
}

output "lifecycle_policy_id" {
  description = "The arn of the lifecycle policy"
  value       = aws_dlm_lifecycle_policy.instance_backup.id
}