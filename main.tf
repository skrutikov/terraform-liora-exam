terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.namespace
      ManagedBy = "Terraform"
    }
  }
}

module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "rds" {
  source = "./modules/rds"

  namespace             = var.namespace
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}

module "ec2" {
  source = "./modules/ec2"

  namespace         = var.namespace
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.networking.web_security_group_id
  user_data = templatefile("${path.module}/install_wordpress.sh", {
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    db_host     = module.rds.address
  })
}

module "ebs" {
  source = "./modules/ebs"

  namespace         = var.namespace
  availability_zone = module.ec2.availability_zone
  instance_id       = module.ec2.instance_id
  size_gb           = 10
}
