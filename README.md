# AWS Ubuntu Desktop VM Module

## Overview

Generally, we have faced several issues around development environments with a diverse team. These include:

- Different underlying hardware causing duplication of effort
- Different underlying hardware having unique issues with software packages (particularly around M1 chips)
- Substantial bloatware around desktop environments causing several "bugs" isolated to individual developers
- Contributor individual hardware performance bottle necks

Several solutions exist to resolve one or more of these issues such as:

- Dev containers to replicate environments across developers
- VM software like Vagrant for creating repeatable VMs
- VSCode extensions committed along side source control

However, these have failed to meet our requirements. Bloatware and different underlying hardware issues persist with individuals having to solve software bugs unique to their hardware. Additionally, performance bottle necks can not be overcome by any software solution.

Due to this, we have frequently used Cloud Servers on AWS with custom built development environment AMIs to solve this issue.

This Terraform module aims to modularize our solution so that it may be reused by the OS community where a similar use case may arise.

## Key Features

1. Spot instance requests with allow for cost effective instances.
2. SSH and RDP access limited to specific IP address ranges.
3. Automated backups of EBS volumes to allow for recovery

## Base Images

[This guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html) details how to create AMI images. We are currently developing some AMIs which will be backlogged however, these are not yet ready.

### Ubuntu 22.04 with Chrome RDP and KDE Plasma 5

One image exists which launches Ubuntu 22.04 with Chrome RDP with KDE Plasma 5. This can be used as a base to get up and running and to begin installing custom software.

This was achieved by the following commands:

```
sudo apt update
sudo apt upgrade
sudo apt install --assume-yes wget tasksel


wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb

sudo apt install tasksel
sudo apt install kde-plasma-desktop

// note the below line does not work and is done manually using nano at the moment.
sudo bash -c ‘echo “exec /etc/X11/Xsession /usr/bin/startplasma-x11” > /etc/chrome-remote-desktop-session
rm chrome-remote-desktop_current_amd64.deb

sudo reboot
```

### Ubuntu 22.04 with Chrome RDP, KDE Plasma 5 and development software.

This configuration uses an AMI which was created by running the script.sh on an instance.

However, the AMI created uses an encrypted volume. So this can not be used for the module which uses a public AMI.

## Set Up Chrome RDP

To set up Chrome RDP, go to the [Chrome RDP Website](https://remotedesktop.google.com/access/) and click on `Set up via SSH`.

From here click `Begin`, `Next` and `Authorise`.

Currently you must SSH into the instance to apply the command but we will provide a remote exec in a future release.

## Resource Material

[Ubuntu Blog on Ubuntu Desktop on GCP](https://ubuntu.com/blog/launch-ubuntu-desktop-on-google-cloud)  
[Guide to install KDE Plasma 5](https://www.tecmint.com/install-kde-plasma-5-in-linux/)
[Guide to generate SSH keys](https://docs.oracle.com/en/cloud/cloud-at-customer/occ-get-started/generate-ssh-key-pair.html)

## Usage
```
module "ubuntu_desktop" {
    source = "../terraform_aws_ubuntu_desktop_vm"
    user_ip_address = "XXX"
    tags = {
        Terraform   = "true"
        Environment = "dev"
  }
}

```

## Requirements
| Name | Version |
|------|---------|
| aws | >= 3.73 |

## Providers
| Name | Version |
|------|---------|
| aws | >=3.73 |

## Modules
[AWS VPC Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)

## Resources
| Name | Type |
|------|------|
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.public_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_key_pair.instance_ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.instance_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_spot_instance_request.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request#argument-reference) | resource |
| [aws_eip.instance_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.instance_eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_role.dlm_lifecycle_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.dlm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_dlm_lifecycle_policy.instance_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr_block | The IPv4 CIDR block of the VPC | `string` | `"10.0.0.0/26"` | No |
| region | The region where the infrastructure will be deployed | `string` | `"us-east-1"` | No |
| public_subnet_cidr_block | The IPv4 CIDR block of the public subnet | `string` | `"10.0.0.0/28"` | No |
| allowed_ingress_cidr_blocks | List of IP addresses allowed access to instance | `list(string)` | `n/a` | Yes |
| instance_spot_price | The maximum price to request on the spot market | `string` | `"0.1888"` | No |
| instance_type | Instance type to use for the instance | `string` | `"t3.xlarge"` | No |
| instance_interruption_behavior | Indicates Spot instance behavior when it is interrupted | `string` | `"stop"` | No |
| instance_block_duration_minutes | The required duration for the Spot instances, in minutes. This value must be a multiple of 60 (60, 120, 180, 240, 300, or 360). The duration period starts as soon as your Spot instance receives its instance ID. At the end of the duration period, Amazon EC2 marks the Spot instance for termination and provides a Spot instance termination notice, which gives the instance a two-minute warning before it terminates. Note that you can't specify an Availability Zone group or a launch group if you specify a duration | `number` | `0` | No |
| instance_ami | The ami used for the instance | `string` | `"ami-0a00786fb4fbf6df7"` | No |
| associate_public_ip_address | Whether to associate a public IP address with an instance in a VPC | `bool` | `true` | No |
| instance_monitoring | Whether detailed monitoring is enabled for EC2 instance | `bool` | `true` | No |
| root_block_device_size | Size of the volume in gibibytes | `number` | `32` | No |
| root_block_device_type | The type of volume | `string` | `"gp3"` | No |
| root_block_device_throughput | Throughput to provision for a volume in mebibytes per second (MiB/s) | `number` | `"125"` | No |
| root_block_device_encryption | Whether to enable volume encryption | `bool` | `true` | No |
| root_block_device_delete_on_termination | Whether the volume should be destroyed on instance termination | `bool` | `true` | No |
| use_ipam_pool | Determines whether IPAM pool is used for CIDR allocation | `bool` | `false` | No |
| public_key | The public key used for the ssh key pair | `string` | `n/a` | Yes |
| terraform_tag | Tag pair for terraform tag | `string` | `"true"` | No |
| environment | Tag pair for environment tag | `string` | `"dev"` | No |

## Outputs
| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The arn of the VPC |
| public_subnet_id | The public subnet ID |
| public_subnet_arn | The public subnet arn |
| public_subnet_cidr_block | The public subnet CIDR block |
| instance_ssh_key_arn | The arn of the instance ssh key pair |
| instance_ssh_key_id | The ID of the instance ssh key pair |
| instance_sg_arn | The arn of the instance security group |
| instance_sg_id | The ID of the instance security group |
| instance_arn | The arn of the instance |
| instance_id | The ID of the instance |
| instance_public_ip | The public ip address of the instance |
| instance_private_ip | The private ip address of the instance |
| elastic_ip_id | The ID of the elastic IP |
| lifecycle_policy_arn | The arn of the lifecycle policy |
| lifecycle_policy_id | The arn of the lifecycle policy |