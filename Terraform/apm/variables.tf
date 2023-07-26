variable "prefix" {
  default     = "APM"
  type        = string
  description = "Project Name"
}
variable "vpc_id" { description = "apm-vpc-id" }
variable "public_subnet_id" { description = "public subnet of server" }
variable "route53_zone_id" { description = "route53 zone id" }
variable "route53_zone_name" { description = "route53 zone name" }
variable "domain_name" { description = "route53 prefix name" }
variable "vpc_cidr" { description = "cidr of vpc" }

#Instance resource
variable "key-pair" { description = "AWS RSA key pair" }
variable "instance_type" {
  default     = "t3.large"
  type        = string
  description = "Type of tf instance"
}

variable "instance_AMI" {
  default = "ami-0beaa649c482330f7" # Amazon linux
  # default     = "ami-0d5bf08bc8017c83b" # Ubuntu 20.04
  type        = string
  description = "AMI for instance"
}

variable "instance_IAM" {
  default     = "Terraform"
  type        = string
  description = "IAM for instance"
}
