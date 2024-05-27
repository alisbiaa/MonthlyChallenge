variable "ami" {
  description = "The Amazon Machine Image ID to use for the instance"
  type        = string
}

variable "key_name" {
  description = "The key pair name to use for the instance"
  type        = string
}

variable "number_of_groups" {
  description = "The number of groups participating in the lab"
  type        = number
}

variable "security_group_ids" {
  description = "The list of existing security group IDs to assign to the instance"
  type        = list(string)
}


variable "instance_type" {
  description = "The instance type of the EC2 instance"
  type        = string
  default     = "t2.micro"
}


variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
