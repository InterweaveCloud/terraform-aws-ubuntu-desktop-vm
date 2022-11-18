# AWS Ubuntu Desktop VM Module

## Diagram

![Architecture Diagram](https://user-images.githubusercontent.com/99090760/202702297-c67954ad-ba2e-4df5-b200-627f0890b351.png)

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

## Features

### Best Practices

#### Networking

- Creates a new independent VPC with a public subnet to remove dependency on pre-existing VPCs.

#### Security

- Spot instance security group only allows [SSH](https://www.ucl.ac.uk/isd/what-ssh-and-how-do-i-use-it#:~:text=SSH%20or%20Secure%20Shell%20is,web%20pages), [VNC](https://discover.realvnc.com/how-to-use-vnc-connect-remote-desktop-software#:~:text=VNC%20stands%20for%20Virtual%20Network,right%20in%20front%20of%20it.) and [RDP](https://www.techtarget.com/searchenterprisedesktop/definition/Remote-Desktop-Protocol-RDP#:~:text=What%20is%20remote%20desktop%20protocol,their%20physical%20work%20desktop%20computers.) inbound access from IP addresses specified by the user. 
- A key pair is created using a public key provided by the user to allow authentication when accessing the instance using port 22(SSH).

#### Instance Configuration

- An elastic IP address is provisioned to preserve the public IP address of the instance between stops and starts. Note: The elastic IP address does not incur charges while the instance is running but will incur charges when stopped.

#### EBS Backup

- A Data Lifecycle Manager lifecycle policy is created which backups the instance daily before midnight and snapshots are retained for 1 week. In the event of catastrophic failure or loss of data, these snapshots can be used to restore EC2 instances. Instances to be managed by this policy are identified by the following tag: {AutomatedEbsBackups = true}.
- Snapshots are taken by the Data Lifecycle Manager.

## Resource Material

[Ubuntu Blog on Ubuntu Desktop on GCP](https://ubuntu.com/blog/launch-ubuntu-desktop-on-google-cloud)  
[Guide to install KDE Plasma 5](https://www.tecmint.com/install-kde-plasma-5-in-linux/)
[Guide to generate SSH keys](https://docs.oracle.com/en/cloud/cloud-at-customer/occ-get-started/generate-ssh-key-pair.html)

## Pre-requisites

To be able to use this module you will need to have [AWS CLI](https://aws.amazon.com/cli/) installed on your local machine. An installation guide can be found [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

## Usage
```
module "ubuntu_desktop" {
    source = "../terraform_aws_ubuntu_desktop_vm"

    user_ip_address = "XXX"
    instance_ami = "XXX"

    tags = {
        Terraform   = "true"
        Environment = "dev"
  }
}

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~>3.18.1 |

## Resources

| Name | Type |
|------|------|
| [aws_dlm_lifecycle_policy.instance_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |
| [aws_eip.instance_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.instance_eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_role.dlm_lifecycle_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.dlm_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_key_pair.instance_ssh_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.instance_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_spot_instance_request.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ingress_cidr_blocks"></a> [allowed\_ingress\_cidr\_blocks](#input\_allowed\_ingress\_cidr\_blocks) | List of IP addresses allowed access to instance | `list(string)` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP address with an instance in a VPC | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | String to affix to any resource names and add to tags | `string` | `"dev"` | no |
| <a name="input_instance_ami"></a> [instance\_ami](#input\_instance\_ami) | AMI to use for the instance | `string` | n/a | yes |
| <a name="input_instance_block_duration_minutes"></a> [instance\_block\_duration\_minutes](#input\_instance\_block\_duration\_minutes) | The required duration for the Spot instances, in minutes. This value must be a multiple of 60 (60, 120, 180, 240, 300, or 360). The duration period starts as soon as your Spot instance receives its instance ID. At the end of the duration period, Amazon EC2 marks the Spot instance for termination and provides a Spot instance termination notice, which gives the instance a two-minute warning before it terminates. Note that you can't specify an Availability Zone group or a launch group if you specify a duration. | `number` | `0` | no |
| <a name="input_instance_interruption_behavior"></a> [instance\_interruption\_behavior](#input\_instance\_interruption\_behavior) | Indicates Spot instance behavior when it is interrupted | `string` | `"stop"` | no |
| <a name="input_instance_monitoring"></a> [instance\_monitoring](#input\_instance\_monitoring) | Whether detailed monitoring is enabled for EC2 instance | `bool` | `true` | no |
| <a name="input_instance_spot_price"></a> [instance\_spot\_price](#input\_instance\_spot\_price) | The maximum price to request on the spot market | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for the instance. | `string` | `"t3.xlarge"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | string to prefix to resource names to make them easier to identify within the console | `string` | `""` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The public key material | `string` | n/a | yes |
| <a name="input_public_subnet_cidr_block"></a> [public\_subnet\_cidr\_block](#input\_public\_subnet\_cidr\_block) | The IPv4 CIDR block of the public subnet | `string` | `"10.0.0.0/28"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the infrastructure will be deployed | `string` | `"us-east-1"` | no |
| <a name="input_root_block_device_delete_on_termination"></a> [root\_block\_device\_delete\_on\_termination](#input\_root\_block\_device\_delete\_on\_termination) | Whether the volume should be destroyed on instance termination | `bool` | `true` | no |
| <a name="input_root_block_device_encryption"></a> [root\_block\_device\_encryption](#input\_root\_block\_device\_encryption) | Whether to enable volume encryption | `bool` | `true` | no |
| <a name="input_root_block_device_size"></a> [root\_block\_device\_size](#input\_root\_block\_device\_size) | Size of the volume in gibibytes | `number` | `32` | no |
| <a name="input_root_block_device_throughput"></a> [root\_block\_device\_throughput](#input\_root\_block\_device\_throughput) | Throughput to provision for a volume in mebibytes per second (MiB/s) | `number` | `125` | no |
| <a name="input_root_block_device_type"></a> [root\_block\_device\_type](#input\_root\_block\_device\_type) | The type of volume | `string` | `"gp3"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to all created resources | `map(any)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The IPv4 CIDR block of the VPC | `string` | `"10.0.0.0/26"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elastic_ip_id"></a> [elastic\_ip\_id](#output\_elastic\_ip\_id) | The ID of the elastic IP |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | The arn of the instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the instance |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | The private ip address of the instance |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | The public ip address of the instance |
| <a name="output_instance_sg_arn"></a> [instance\_sg\_arn](#output\_instance\_sg\_arn) | The arn of the instance security group |
| <a name="output_instance_sg_id"></a> [instance\_sg\_id](#output\_instance\_sg\_id) | The ID of the instance security group |
| <a name="output_instance_ssh_key_arn"></a> [instance\_ssh\_key\_arn](#output\_instance\_ssh\_key\_arn) | The arn of the instance ssh key pair |
| <a name="output_instance_ssh_key_id"></a> [instance\_ssh\_key\_id](#output\_instance\_ssh\_key\_id) | The ID of the instance ssh key pair |
| <a name="output_lifecycle_policy_arn"></a> [lifecycle\_policy\_arn](#output\_lifecycle\_policy\_arn) | The arn of the lifecycle policy |
| <a name="output_lifecycle_policy_id"></a> [lifecycle\_policy\_id](#output\_lifecycle\_policy\_id) | The arn of the lifecycle policy |
| <a name="output_public_subnet_arn"></a> [public\_subnet\_arn](#output\_public\_subnet\_arn) | The public subnet arn |
| <a name="output_public_subnet_cidr_block"></a> [public\_subnet\_cidr\_block](#output\_public\_subnet\_cidr\_block) | The public subnet CIDR block |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | The public subnet ID |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | The arn of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/InterweaveCloud/terraform_aws_ubuntu_desktop_vm/issues) to report any bugs or file feature requests.

## Contributors
| Name | Role |
|------|------|
| [Muhammad Hasan](https://www.linkedin.com/in/muhammad-hasan-b2553221a/) | Lead Developer |
| [Faizan Raza](https://www.linkedin.com/in/faizan-raza-997808206/) | Developer |

## Style Guidelines

### Naming Convention

Throughout the module, the naming convention used is as follows:
- For Terraform resource names, the names consist of lowercase characters and _ to represent spaces in the name.
- For AWS resource names, the names consist of lowercase characters and - to represent spaces in the name, with the <a name="input_prefix"></a> [prefix](#input\_prefix) variable attached to the beginning of the name and the <a name="input_environment"></a> [environment](#input\_environment).

## Resources Used
[Terraform Docs](https://terraform-docs.io/) used for generating documentation.

[def]: terraform-aws-ubuntu-desktop-vm/Architecture-Diagram.png
