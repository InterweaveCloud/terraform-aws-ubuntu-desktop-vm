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

variable "instance_spot_price" {
  type = string
  default = "0.1888"
  description = "The maximum price to request on the spot market"
}

variable "instance_type" {
  type = string
  default = "t3.xlarge"
  description = "The instance type"
}

variable "instance_interruption_behavior" {
  type = string
  default = "stop"
  description = "Indicates Spot instance behavior when it is interrupted"
}

variable "instance_block_duration_minutes" {
  type = number
  default = 0
  description = "The required duration for the Spot instances, in minutes"
}

variable "instance_ami" {
  type = string
  default = "ami-0a00786fb4fbf6df7"
  description = "The ami used for the instance"
}

variable "associate_public_ip_address" {
  type = bool
  default = true
  description = "Whether to associate a public IP address with an instance in a VPC"
}

variable "instance_monitoring" {
  type = bool
  default = true
  description = "Whether detailed monitoring is enabled for EC2 instance"
}

variable "root_block_device_size" {
  type = number
  default = 32
  description = "Size of the volume in gibibytes"
}

variable "root_block_device_type" {
  type = string
  default = "gp3"
  description = "The type of volume"
}

variable "root_block_device_throughput" {
  type = number
  default = 125
  description = "Throughput to provision for a volume in mebibytes per second (MiB/s)"
}

variable "root_block_device_encryption" {
  type = bool
  default = false
  description = "Whether to enable volume encryption"
}

variable "root_block_device_delete_on_termination" {
  type = bool
  default = true
  description = "Whether the volume should be destroyed on instance termination"
}