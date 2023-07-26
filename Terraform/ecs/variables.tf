variable "prefix" {
  type        = string
  description = "Project Name"
}

variable "vpc_id" { description = "ecs_vpc_id" }
variable "vpc_cidr" { description = "vpc inner cidr" }
variable "public_subnets_id" { description = "public subnets of loadbalancer" }
variable "route53_zone_id" { description = "route53 zone id" }
variable "route53_zone_name" { description = "route53 zone name" }
variable "max_capacity" { description = "autoscaling max" }
variable "min_capacity" { description = "autoscaling min" }

variable "domain_name" { description = "domain prefix of ecs" }
variable "private_subnets_id" { description = "private subnets of loadbalancer" }
variable "apm-server-ip" { description = "apm server private ip" }
variable "db-domain" { description = "db dns" }
variable "db-user" { description = "db username" }
variable "db-pw" { description = "db pw" }

variable "task-def" { description = "task definition file" }

variable "lb-in-port" {
  default     = [80, 443]
  description = "load balancer ingress ports"
}

variable "target-port" {
  default     = 8080
  description = "container port"
}

variable "listen-port" {
  default = 80
}

variable "test-listen-port" {
  default = 8888
}
