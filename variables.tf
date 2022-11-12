variable "vpc_CIDR_block" {
  type = string
  default = "10.0.0.0/16"
  description = "The IPv4 CIDR block of the VPC"
}

variable "vpc_name" {
  type = string
  default = "ubuntu-desktop-vpc"
  description = "The name of the VPC"
}

variable "region" {
  type = string
  default = "us-east-1"
  description = "The region where the infrastructure will be deployed"
}

variable "public_subnet_CIDR_block" {
  type = string
  default = "10.0.0.0/28"
  description = "The IPv4 CIDR block of the public subnet"
}

variable "instance_ssh_key_pair_name" {
  type = string
  default = "instance-ssh-key"
  description = "The ssh key pair name"
}

variable "instance_sg_name" {
  type = string
  default = "instance-ssh-key"
  description = "The instance security group name"
}

variable "user_ip_address" {
  type = string
  description = "The home IP address of the user"
}