provider "aws" {
  region = var.region
}

module "ecs-vpc" {
  source              = "./vpc"
  prefix              = var.project_name
  vpc_cidr_block      = "10.34.0.0/20"
  availability_zones  = ["us-east-2a", "us-east-2c"]
  cidr_for_public     = ["10.34.1.0/24", "10.34.3.0/24"]
  cidr_for_private    = ["10.34.2.0/24", "10.34.4.0/24"]
  cidr_for_db_private = ["10.34.11.0/24", "10.34.13.0/24"]
}

module "ecs-apm" {
  source            = "./apm"
  prefix            = var.project_name
  vpc_id            = module.ecs-vpc.vpc_id
  public_subnet_id  = module.ecs-vpc.public_subnet_id
  vpc_cidr          = module.ecs-vpc.cidr_block
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  route53_zone_name = data.aws_route53_zone.main.name
  domain_name       = "pinpoint"
  key-pair          = var.key-pair
}

module "ecs" {
  source            = "./ecs"
  prefix            = "chwan-ecs1"
  vpc_id            = module.ecs-vpc.vpc_id
  vpc_cidr          = module.ecs-vpc.cidr_block
  public_subnets_id = module.ecs-vpc.public_subnet_id
  route53_zone_id   = data.aws_route53_zone.main.zone_id
  route53_zone_name = data.aws_route53_zone.main.name

  max_capacity = 30
  min_capacity = 5

  domain_name        = "web"
  private_subnets_id = slice(module.ecs-vpc.private_subnet_id, 0, 2)
  task-def           = "./taskdef1.json"
  apm-server-ip      = module.ecs-apm.apm-private-ip
  db-domain          = module.rds.cluster-dns
  db-user            = module.rds.db_user
  db-pw              = module.rds.db_pw
}

module "rds" {
  source                = "./rds"
  prefix                = var.project_name
  private_subnets_id    = module.ecs-vpc.db_private_subnet_id
  vpc_security_group_id = module.ecs.task-security-group-id
  key-pair              = var.key-pair
}

data "aws_route53_zone" "main" {
  name = "chwani.com"
}

terraform {
  backend "s3" {
    bucket  = "chwan-tfstate"
    key     = "terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
