locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "networking" {
  source = "./modules/networking"

  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
}

module "platform" {
  source     = "./modules/platform"
  depends_on = [module.networking]

  region            = var.region
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  ecs_cluster_name  = "${var.environment}-fargate-cluster"
  public_subnet_ids = module.networking.public_subnet_ids
  ecs_domain_name   = var.ecs_domain_name
}
