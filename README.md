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

### SSH Login to your Instance

1. Connect to the VPN

    > http://sjc-cci-vpn-cluster-appd.cisco.com/ssl

2. Download the Access Key

    > Link to be added

3. Change the permission for the access key

    ```shell
    chown +x key.pem
    ```
4. Login to your instance using the IP + User provided by the instructor

    ```shell
    ssh -i </path/to/your/key.pem> <user>@<ip>
    ```


### Set up your instance

1. Download / Install Terraform
   > [Documentation](https://developer.hashicorp.com/terraform/install)

   ```shell
   sudo yum install -y yum-utils shadow-utils
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
   sudo yum -y install terraform
   ```

2. Check your Terraform version

   ```shell
   terraform -version
   ```
   >    Terraform v1.8.4
   
3. Download / Install Ansible

   > [Documentation](https://docs.ansible.com/ansible/2.9/installation_guide/intro_installation.html#)
   
   ```shell
   sudo dnf -y install ansible-core
   ```
   
4. Check Ansible Version

   ```shell
   ansible --version
   ```
   
   > ansible [core 2.14.14]

5. Ensure the challenge dir exist

   ```shell
   ll ~/
   ```
   > `drwxr-xr-x. 5 root root 81 May 28 11:15 challenge`

6. Changing dir ownership of the challenge

   ```shell
   sudo chown -R automation:automation ~/challenge/
   ll ~/
   ```

## Spin-up resources

> [!NOTE]
> For this section we are working from `~/challenge/hands-on/terraform` dir.
> The user you are using has sudo privileges

### Terraform

1. Navigate to `hands-on/terraform/`

   ```shell
   cd ~/challenge/hands-on/terraform/
   ```

2. Review `variables.tf`

   In the context of Terraform, a variables.tf file is used to define the input variables for a Terraform module or root
   configuration.
   These input variables serve as parameters that can be passed into Terraform configurations to customize and parameterize
   your infrastructure definitions.

   | Variable             | Description                                                       |
   |----------------------|-------------------------------------------------------------------|
   | `ami`                | The Amazon Machine Image ID to use for the instance               |
   | `key_name`           | The key pair name to use for the instance                         |
   | `instance_type`      | The instance type of the EC2 instance                             |
   | `security_group_ids` | The list of existing security group IDs to assign to the instance |
   | `group_name`         | To distinguish between vms for each group                         |
   | `number_of_vms`      | The number of vms to spin-up                                      |

3. Create `terraform.tfvars` and add the variables from the table above

   ```shell
   vi terraform.tfvars
   ```
   
   Paste the following values
   
   ```terraform
   ami = "ami-0134dde2b68fe1b07"
   key_name = "<key-name>"
   number_of_vms = 2
   instance_type="t2.micro"
   security_group_ids = ["sg-0450ce90fb7652d86", "sg-0b6c2c97b48d52bd7"]
   group_name = "<group-name>"
   ```
> [!CAUTION]
> Please do not put more than `2` for the variable `number_of_vms`.

4. Make sure `access_key` and `secret_key` are set up in `main.tf`.
   ```shell
   cat main.tf
   ```
   ```terraform
   access_key = "...."
   secret_key = "...."
   ```

5. Action

   ```shell
   terraform init
   terraform plan
   terraform apply
   terraform output
   ```
6. Take notes of the ec2 instance ip you've created

   ```shell
   terraform output
   ```
   ```text
   lab_instance_public_ips = [
    "1.2.3.4", <--
    "3.4.5.6", <--
   ]
   ```

## Instrument Machine Agent

### Ansible

```shell
ansible-playbook -i inventory.ini -u ec2-user --private-key <key.pem> playbook.yml --ssh-common-args='-o StrictHostKeyChecking=no'
```


## End lab


   ```shell
   cd ~/challenge/hands-on/terraform/
   terraform destroy
   exit
   ```
