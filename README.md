## Scope
* **Hands-on with Terraform and Ansible**: Participants will engage in a practical exercise involving `Terraform` and `Ansible`.
* **Provisioning EC2 Instances with Terraform**: Using Terraform, participants will deploy multiple EC2 instances in the AWS cloud.
* **Configuring Machine Agent with Ansible**: Leveraging Ansible, participants will install and configure the `machine agent` within the EC2 instances provisioned by Terraform.
* **Introduction to Automation**: The primary objective is to introduce participants to automation principles, showcasing the speed and efficiency gained through the automation of infrastructure deployment and configuration tasks.

## Demo

* Spin up an EC2 per group using Terraform
* Ensures the latest versions of `Git`, `yum-utils`, and `dnf-plugins-core` are installed.
* Clones or updates the `MonthlyChallenge` repository from a GitHub URL.
* Configures the AWS access key in the main.tf file of the Terraform project.
* Configures the AWS secret key in the main.tf file of the Terraform project.
* Creates a user named `automation` with membership in the `wheel` group, ensuring the user's home directory is created if it doesn't exist.
* Checks if SSH public keys exist for the `ec2-user` and copies them to the `automation` user's SSH directory.
* Ensures the appropriate permissions are set for the `automation` user's SSH directory and SSH public keys file.
* Copies the SSH private key to the `automation` user's SSH directory with appropriate permissions.

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
    chmod 600 key.pem
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
   sudo chown -R automation:automation /home/automation
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

> [!TIP]
> In the context of Terraform, a `variables.tf` file is used to define the input variables for a Terraform module or root
configuration.
These input variables serve as parameters that can be passed into Terraform configurations to customize and parameterize
your infrastructure definitions. [Documentation](https://developer.hashicorp.com/terraform/language/values/variables)

| Variable             | Description                                                       |
   |----------------------|-------------------------------------------------------------------|
| `ami`                | The Amazon Machine Image ID to use for the instance               |
| `key_name`           | The key pair name to login to the instance using ansible          |
| `instance_type`      | The instance type of the EC2 instance                             |
| `security_group_ids` | The list of existing security group IDs to assign to the instance |
| `group_name`         | To distinguish between vms for each group                         |
| `number_of_vms`      | The number of vms to spin-up                                      |

3. Prepare input variables for Terraform

   a. Creating `terraform.tfvars`

   Create a `terraform.tfvars` file and add the variables from the table above.

>    [!CAUTION]
>    Please do not set the number_of_vms variable to more than 2.

Use the following command to create and edit the file:

   ```shell
   vi terraform.tfvars
   ```

   ```terraform
   ami = "..."       <--
   key_name = "generic-vm"
   number_of_vms = 2
   instance_type= "..."       <--
   security_group_ids = ["sg-0450ce90fb7652d86", "sg-0b6c2c97b48d52bd7", "sg-0b0bc535615f12b47"]
   group_name = "..."       <--
   ```

b. Finding the Amazon Machine Image (AMI)

[//]: # (  ami-0134dde2b68fe1b07 )
Refer to the [Red Hat Docs](https://access.redhat.com/solutions/15356) to find the Amazon Machine Image (AMI) with the following criteria:

* Amazon Region ID: `eu-central-1`
* Distribution Version: `RHEL 9`
* Architecture: `x86_64`

c. Selecting the Instance Type

Refer to this [AWS EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/) link. For this challenge, use the `t2.micro` instance type.

d. Setting the Group Name

The `group_name` is the group you are assigned to at the beginning of the challenge. For example, `group_1`. This is used to prefix the VM on `RunOn` to differentiate between resources.

4. Initializing, Planning, and Applying Terraform

   a. Initializing Terraform

   Run the following command to initialize Terraform. This command prepares your working directory by downloading the necessary provider plugins.

   ```shell
   terraform init
   ```

   b. Planning the Terraform Deployment

   Run the following command to create an execution plan. This command shows you what actions Terraform will take to reach the desired state defined in your configuration files.

   ```shell
   terraform plan
   ```  

   c. Applying the Terraform Configuration

   Run the following command to apply the changes required to reach the desired state of the configuration. This command provisions the resources defined in your configuration files.

      ```shell
   terraform apply
   ```  

5. Taking Note of the EC2 Instance IP

   After applying the configuration, run the following command to take note of the EC2 instance Public IP addresses created by Terraform:

   ```shell
   terraform output
   ```
   ```text
   lab_instance_public_ips = [
    "1.2.3.4",       <--
    "3.4.5.6",       <--
   ]
   ```

## Instrument Machine Agent

### Prepare the variables for Ansible

> [!NOTE]
> For this section we are working from `~/challenge/hands-on/ansible` dir.

1. Creating an `inventory.ini` File

> [!TIP]
> The `inventory.ini` file in Ansible is a configuration file used to define the hosts and groups of hosts on which Ansible commands, modules, and playbooks will be executed. This file acts as a dynamic or static inventory source, listing the managed nodes in your infrastructure. It allows you to organize and group these nodes logically, making it easier to manage and automate tasks across different environments.

a. Navigate to the Ansible project directory:
   ```shell
   cd ~/challenge/hands-on/ansible
   ```
b. Create and edit the inventory.ini file using the following command:
   ```shell
   vi inventory.ini
   ```
c. Add the following content to the inventory.ini file:
   ```ini
   [all:vars]
   ansible_user=ec2-user
   ansible_ssh_private_key_file=~/.ssh/generic-vm.pem
   ansible_ssh_common_args='-o StrictHostKeyChecking=no'

   [hands_on_hosts]
   <unique_host_id> ansible_host=<instance_public_ip_1>
   <unique_host_id> ansible_host=<instance_public_ip_2>
   ```

- Replace `instance_public_ip_1` and `instance_public_ip_2` with the public IP addresses of the instances you retrieved from Terraform after applying.

- To retrieve the public IP addresses, navigate to the Terraform project directory and run the following command:
   ```shell
   cd ~/challenge/hands-on/terraform && terraform output
   ```
- Ensure that `unique_host_id` is a unique identifier for each host: [Documentation](https://docs.appdynamics.com/appd/24.x/latest/en/infrastructure-visibility/machine-agent/configure-the-machine-agent/machine-agent-configuration-properties#id-.MachineAgentConfigurationPropertiesv24.1-unique_host_idUniqueHostID). It's recommended to prefix it with your group name:
   - `group-1-vm-1`
   - `group-1-vm-2`
- The `ansible_ssh_private_key_file` variable indicates the path to the private key file that should be used when connecting to the servers. Adjust the path if your private key file is located elsewhere.

2. Setting Configuration Variables in `hands_on_hosts.yml`

   a. Navigate to the Ansible project directory:
   ```shell
   cd ~/challenge/hands-on/ansible
   ```
   b. Create the `group_vars` directory if it doesn't exist:
   ```shell
   mkdir group_vars
   ```
   c. Now, create and edit the `hands_on_hosts.yml` file using the following command:
   ```shell
   vi group_vars/hands_on_hosts.yml
   ```

   d. Add the configuration variables to the `hands_on_hosts.yml` file

   | Variable                     | Description                       |
      |------------------------------|-----------------------------------|
   | `machine_agent_download_url` | Machine agent artifact endpoint   |
   | `machineAgentHomeDirectory`  | Machine agent home directory      |
   | `appdArtifactsHomeDirectory` | AppDynamics Artifacts directory   |
   | `appdynamicsUser`            | The user to run the machine agent |

   ```shell
   vi group_vars/hands_on_hosts.yml
   ```
   ```ini
   machine_agent_download_url: "https://download-files.appdynamics.com/download-file/machine-bundle/24.4.0.4150/machineagent-bundle-64bit-linux-24.4.0.4150.zip"
   machineAgentHomeDirectory: "/opt/appdynamics/machine-agent"
   appdArtifactsHomeDirectory : "/opt/appdynamics/artifacts"
   appdynamicsUser: "appdynamics"
   ```

3. Creating .env File for Machine Agent Configuration

   a. Create a .env file to store machine agent configuration properties. This file will be used for configuring the machine agent.
   ```shell
   vi ~/challenge/hands-on/ansible/.env
   ````
   b. Refer to the  [documentation](https://docs.appdynamics.com/appd/24.x/latest/en/infrastructure-visibility/machine-agent/configure-the-machine-agent/machine-agent-configuration-properties) to fill the .env file.

> [!IMPORTANT]
> Only include the `account` and `controller` information. Optionally, you can enable `SIM` if needed.

   c. Add the variables
   ```dotenv
   APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=...       <--
   APPDYNAMICS_AGENT_ACCOUNT_NAME=...       <--
   APPDYNAMICS_CONTROLLER_HOST_NAME=...       <--
   APPDYNAMICS_CONTROLLER_PORT=443
   APPDYNAMICS_CONTROLLER_SSL_ENABLED=true
   APPDYNAMICS_SIM_ENABLED=...       <--
   ```

4. Ensure AppDynamics Machine Agent Service is Enabled and Started

   a. Navigate to the appropriate directory:
   ```shell
   cd ~/challenge/hands-on/ansible/roles/add_ma_service/tasks
   ```
   
   b. Open the `main.yml` file in an editor:
   ```shell
   vi main.yml
   ```
   
   c. Modify the following task to ensure that the AppDynamics Machine Agent service is both `enabled` and `started` on the target hosts, refer to this [documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/systemd_service_module.html#ansible-collections-ansible-builtin-systemd-service-module):
   ```yaml
    - name: Ensure AppDynamics Machine Agent Service is Enabled and Started
      become: true
      ansible.builtin.<...>:
         name: <...>
         enabled: <...>
         state: <...>
   ```

[//]: # (- name: Ensure AppDynamics Machine Agent Service is Enabled and Started)
[//]: # (  become: true)
[//]: # (  ansible.builtin.systemd_service:)
[//]: # (  name: appdynamics-machine-agent.service)
[//]: # (  enabled: yes)
[//]: # (  state: started)

5. Directory Structure for Ansible Configuration

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
       │   │   └── main.yml       <--
       │   └── templates
       │       └── appdynamics-machine-agent.service.j2
       ├── download_ma
       │   └── tasks
       │       └── main.yaml
       └── setup
           └── tasks
               └── main.yml

   ```

6. Run Ansible Playbook

   Execute the following command to run the Ansible playbook using the provided inventory file:

   ```shell
   cd ~/challenge/hands-on/ansible
   ansible-playbook -i inventory.ini playbook.yml
   ```

   This command will execute the `playbook.yml` playbook using the inventory file specified with the `-i` option.

7. Check the controller

   a. Open the controller

   b. Navigate to the `servers` tab

   c. Find your machine agents

   d. take a screenshot

## Destroy Terraform Resources and Exit

1. Navigate to the Terraform project directory:
   ```shell
   cd ~/challenge/hands-on/terraform/
   ```

2. Execute the following command to destroy the Terraform-managed infrastructure:
   ```shell
   terraform destroy
   ```

3. After confirming the destruction of resources, exit the terminal:
   ```shell
   exit
   ```

