variable "prefix" {
  type        = string
  description = "Project Name"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR for VPC"
}

variable "cidr_for_public" {
  type        = list(any)
  description = "CIDR for public subnets"
}

variable "cidr_for_private" {
  type        = list(any)
  description = "CIDR for private subnets"
}

variable "cidr_for_db_private" {
  type        = list(any)
  description = "CIDR for db private subnets"
}

variable "availability_zones" {
  type        = list(any)
  description = "List of AZs"
}
