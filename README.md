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

## Inputs
| Name | Description | Type | Default | Required |
|------------------------------------------------|
| vpc_CIDR_block | The IPv4 CIDR block of the VPC | `String` | `10.0.0.0/15` | No |
| vpc_name | The name of the VPC | `String` | `ubuntu-desktop-vpc` | No |
| region | The region where the infrastructure will be deployed | `string` | `us-east-1` | No |
| public_subnet_CIDR_block | The IPv4 CIDR block of the public subnet | `string` | No |
| instance_ssh_key_pair_name | The ssh key pair name | `string` | No |

## Outputs
| Name | Description |
|--------------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The arn of the VPC |
| public_subnet_id | The public subnet ID |
| public_subnet_arn | The public subnet arn |
| public_subnet_cidr_block | The public subnet CIDR block |
| instance_ssh_key_arn | The arn of the instance ssh key paid |
| instance_ssh_key_id | The ID of the instance ssh key paid |