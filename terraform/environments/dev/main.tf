terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Remote state - S3 backend in production
  # backend "s3" {
  #   bucket = "bae-terraform-state"
  #   key    = "dev/terraform.tfstate"
  #   region = "us-gov-west-1"
  # }
}

provider "aws" {
  region = "us-gov-west-1"  # GovCloud - WorkSpaces compatible
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = "bae-devops"
  environment  = "dev"
  azs          = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
}

module "eks" {
  source             = "../../modules/eks"
  project_name       = "bae-devops"
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  node_instance_types = ["t3.medium"]
  node_desired       = 2
  node_min           = 2
  node_max           = 4
}
