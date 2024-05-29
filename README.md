## Demo

- Spin up an EC2 per group using Terraform
- Install the following GitHub on each machine
- Create `automation` user
- Clone the repository
- Set up AWS credentials
- Share the private key that would allow you to spin up resources
- Hand over each group the IP of their Control Machine

## Setup

### Requirements

- Access to an AppDynamics Controller.
- Access to RunOn.

## Prepare the environment

### SSH Login to your Instance

1. Download the Access Key

    > Link to be added

2. Change the permission for the access key

    ```shell
    chown +x key.pem
    ```
3. Login to your instance using the IP + User provided by the instructor

    ```shell
    ssh -i </path/to/your/key.pem> <user>@<ip>
    ```


### Set up your instance
> [!NOTE]
> The user you are using has sudo privileges

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

> [!CAUTION]
> Please do not put more than `2` for the variable `number_of_vms`.

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

2. Make sure `access_key` and `secret_key` are set up in `main.tf`.
   ```shell
   cat main.tf
   ```
   ```terraform
   access_key = "...."
   secret_key = "...."
   ```

3. Action

   ```shell
   terraform init
   terraform plan
   terraform apply
   terraform output
   ```
4. Take notes of the ec2 instance ip you've created

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

### Prepare the variables for Ansible

> [!NOTE]
> For this section we are working from `~/challenge/hands-on/ansible` dir.

1. Create an `inventory.ini`

> [!TIP]
> The `inventory.ini` file in Ansible is a configuration file used to define the hosts and groups of hosts on which Ansible commands, modules, and playbooks will be executed. This file acts as a dynamic or static inventory source, listing the managed nodes in your infrastructure. It allows you to organize and group these nodes logically, making it easier to manage and automate tasks across different environments.

   ```shell
   vi inventory.ini
   ```
   ```ini
   [all:vars]
   ansible_user=ec2-user
   ansible_ssh_private_key_file=</path/to/your/key.pem>
   ansible_ssh_common_args='-o StrictHostKeyChecking=no'

   [hands_on_hosts]
   <unique_host_id> ansible_host=<instance_public_ip>
   <unique_host_id> ansible_host=<instance_public_ip>
   ```
   
   - `instance_public_ip` is what you've retrieved from terraform after `apply`.

   - You can always run the command
   ```shell
   cd ~/challenge/hands-on/terraform && terraform output
   ```
   - `unique_host_id` is something you are familiar with: [Documentation](https://docs.appdynamics.com/appd/24.x/latest/en/infrastructure-visibility/machine-agent/configure-the-machine-agent/machine-agent-configuration-properties#id-.MachineAgentConfigurationPropertiesv24.1-unique_host_idUniqueHostID). I suggest prefixing it with your group name: 
     - `group-1-vm-1`
     - `group-1-vm-2`
   - The `ansible_ssh_private_key_file` variable indicates the path to the private key file that should be used when connecting to the servers.

2. Create `hands_on_hosts.yml` inside `group_vars`
   ```shell
   mkdir group_vars
   touch group_vars/hands_on_hosts.yml
   ```
3. Add the variables

   | Variable                     | Description                       |
   |------------------------------|-----------------------------------|
   | `machine_agent_download_url` | Machine agent artifact endpoint   |
   | `machineAgentHomeDirectory`  | Machine agent home directory      |
   | `appdArtifactsHomeDirectory` | AppDynamics Artifacts directory   |
   | `appdynamicsUser`            | The user to run the machine agent |

   ```shell
   vi group_vars/hands_on_hosts.yml
   ```
   ```terraform
   machine_agent_download_url: "https://download-files.appdynamics.com/download-file/machine-bundle/24.4.0.4150/machineagent-bundle-64bit-linux-24.4.0.4150.zip"
   machineAgentHomeDirectory: "/opt/appdynamics/machine-agent"
   appdArtifactsHomeDirectory : "/opt/appdynamics/artifacts"
   appdynamicsUser: "appdynamics"
   ```
   
4. Prepare Appdynamics Controller Variables

   Create `.env` 
   ```shell
   vi .env
   ````
   Add the variables
   ```dotenv
   APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=...
   APPDYNAMICS_AGENT_ACCOUNT_NAME=...
   APPDYNAMICS_CONTROLLER_HOST_NAME=...
   APPDYNAMICS_CONTROLLER_PORT=443
   APPDYNAMICS_CONTROLLER_SSL_ENABLED=true
   APPDYNAMICS_SIM_ENABLED=true
   ```
   
5. This is how your directory tree should look like at this point

   ```
   .
   ├── .env       <--
   ├── ansible.cfg
   ├── group_vars       <--
   │   └── hands_on_hosts.yml       <--
   ├── inventory.ini       <--
   ├── playbook.yml
   └── roles
   ├── add_ma_service
   │   ├── tasks
   │   │   └── main.yml
   │   └── templates
   │       └── appdynamics-machine-agent.service.j2
   ├── download_ma
   │   └── tasks
   │       └── main.yaml
   └── setup
   │   └── tasks
   │       └── main.yaml

   ```
   
6. Action
   ```shell
   ansible-playbook -i inventory.ini playbook.yml
   ```

### Check the controller

## End lab

   ```shell
   cd ~/challenge/hands-on/terraform/
   terraform destroy
   exit
   ```
