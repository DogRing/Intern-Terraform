variable "prefix" { description = "project name" }
variable "key-pair" { description = "AWS RSA key pair" }
variable "vpc_security_group_id" { description = "ecs security group" }
variable "private_subnets_id" { description = "private subnet for db" }

#Instance resource
variable "instance_type" {
  default     = "t3.micro"
  type        = string
  description = "Type of tf instance"
}

variable "instance_AMI" {
  default     = "ami-02a083aab1073a459" # Linux
  type        = string
  description = "AMI for instance"
}
