provider "aws" {
  region = var.aws_region
#  access_key = "my-access-key"
#  secret_key = "my-secret-key"
}

resource "aws_instance" "lab_instance" {
  count = var.number_of_groups

  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = {
    Name = "LabGroup-${format("%02d", count.index + 1)}"
    Owner = "asbiaaza"
  }
}
