```shell
cd terraform
terraform init
terraform plan
terraform apply
terraform output
cd ansible
ansible-playbook -i inventory.ini -u ec2-user --private-key /Users/asbiaaza/Documents/vm/asbiaaza-key.pem playbook.yml --ssh-common-args='-o StrictHostKeyChecking=no'
```
