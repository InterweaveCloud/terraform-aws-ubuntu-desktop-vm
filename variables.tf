variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/26"
  description = "The IPv4 CIDR block of the VPC"
}

variable "use_ipam_pool" {
  description = "Determines whether IPAM pool is used for CIDR allocation"
  type        = bool
  default     = false
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region where the infrastructure will be deployed"
}

variable "public_subnet_cidr_block" {
  type        = string
  default     = "10.0.0.0/28"
  description = "The IPv4 CIDR block of the public subnet"
}

variable "public_key" {
  type        = string
  description = "The public key material"
}

variable "allowed_ingress_cidr_blocks" {
  type        = list(string)
  description = "List of IP addresses allowed access to instance"
}

variable "instance_spot_price" {
  type        = string
  default     = null
  description = "The maximum price to request on the spot market"
}

variable "instance_type" {
  type        = string
  default     = "t3.xlarge"
  description = "Instance type to use for the instance."
}

variable "instance_interruption_behavior" {
  type        = string
  default     = "stop"
  description = "Indicates Spot instance behavior when it is interrupted"
}

variable "instance_block_duration_minutes" {
  type        = number
  default     = 0
  description = "The required duration for the Spot instances, in minutes. This value must be a multiple of 60 (60, 120, 180, 240, 300, or 360). The duration period starts as soon as your Spot instance receives its instance ID. At the end of the duration period, Amazon EC2 marks the Spot instance for termination and provides a Spot instance termination notice, which gives the instance a two-minute warning before it terminates. Note that you can't specify an Availability Zone group or a launch group if you specify a duration."
}

variable "instance_ami" {
  type        = string
  description = "AMI to use for the instance"
}

variable "associate_public_ip_address" {
  type        = bool
  default     = true
  description = "Whether to associate a public IP address with an instance in a VPC"
}

variable "instance_monitoring" {
  type        = bool
  default     = true
  description = "Whether detailed monitoring is enabled for EC2 instance"
}

variable "root_block_device_size" {
  type        = number
  default     = 32
  description = "Size of the volume in gibibytes"
}

variable "root_block_device_type" {
  type        = string
  default     = "gp3"
  description = "The type of volume"
}

variable "root_block_device_throughput" {
  type        = number
  default     = 125
  description = "Throughput to provision for a volume in mebibytes per second (MiB/s)"
}

variable "root_block_device_encryption" {
  type        = bool
  default     = true
  description = "Whether to enable volume encryption"
}

variable "root_block_device_delete_on_termination" {
  type        = bool
  default     = true
  description = "Whether the volume should be destroyed on instance termination"
}

variable "terraform_tag_value" {
  type        = string
  default     = "true"
  description = "Value for terraform tag"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "String to affix to any resource names and add to tags"
}

variable "prefix" {
  type        = string
  default     = ""
  description = "string to prefix to resource names to make them easier to identify within the console"
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Tags to add to all created resources"
}