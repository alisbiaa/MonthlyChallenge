## Summary

* [Markdown]

## Setup

### Requirements

- Access to an AppDynamics Controller.
- Access to RunOn.
- Access to AppDynamics/Cisco VPN.

### Overview [20mn]

- Spin up an EC2 per group using Terraform
- Install the following GitHub on each machine
- Create `automation` user
- Clone the repository
- Set up AWS credentials
- Share the private key that would allow you to spin up resources
- Hand over each group the IP of their Control Machine

## Prepare the environment [20mn]

### Install Terraform

[Documentation](https://developer.hashicorp.com/terraform/install)

```shell
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
```

### Install Ansible

[Documentation](https://docs.ansible.com/ansible/2.9/installation_guide/intro_installation.html#)

```shell
sudo dnf install ansible-core
ansible --version
```

## Spin-up resources

### Terraform

Navigate to `terraform/hands-on`

```shell
cd ~/challenge/terraform/hands-on
```

Review `variables.tf`
In the context of Terraform, a variables.tf file is used to define the input variables for a Terraform module or root
configuration.
These input variables serve as parameters that can be passed into Terraform configurations to customize and parameterize
your infrastructure definitions.

| Variable             | Value                   | Description                                                       |
|----------------------|-------------------------|-------------------------------------------------------------------|
| `ami`                | `ami-0134dde2b68fe1b07` | The Amazon Machine Image ID to use for the instance               |
| `key_name`           | `asbiaaza-key`          | The key pair name to use for the instance                         |
| `instance_type`      | `t2.micro`              | The instance type of the EC2 instance                             |
| `security_group_ids` |                         | The list of existing security group IDs to assign to the instance |

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html

## Instrument Machine Agent

### Ansible

```shell
ansible-playbook -i inventory.ini -u ec2-user --private-key /Users/asbiaaza/Documents/vm/asbiaaza-key.pem demo.yml --ssh-common-args='-o StrictHostKeyChecking=no'
```

## Add custom extension

### Ansible

## End lab

### Terraform
