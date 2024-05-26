## Summary
* [Markdown]
## Setup
### Overview
- Spin up an EC2 per group using Terraform
- Install the following GitHub on each machine
- Create a challenge user
- Clone the repository
- Set up AWS credentials
- Import the private key that would allow you to spin up resources
- Hand over each group the IP of their Control Machine.
### Requirements
- Access to an AppDynamics Controller.
- Access to RunOn.
- Access to AppDynamics/Cisco VPN.

## Spin-up resources
### Terraform
```shell
terraform init
terraform plan
terraform output -json > output.json
terraform destroy
```

https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html

## Instrument Machine Agent
### Ansible

## Add custom extension
### Ansible

## End lab
### Terraform
