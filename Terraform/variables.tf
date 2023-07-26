variable "region" {
  default     = "us-east-2"
  type        = string
  description = "Region"
}

variable "project_name" {
  default = "chwan-ecs"
  type    = string
}

variable "cidr_for_local" {
  default = [

  ]
  type = list(any)
}

variable "key-pair" { description = "AWS RSA key pair" }
