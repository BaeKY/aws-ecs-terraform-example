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

module "application" {
  source                = "./modules/application_test/infrastructure"

  depends_on = [module.platform]
  docker_container_port = var.docker_container_port
  desired_task_number   = var.desired_task_number
  docker_image_url      = "${var.aws_account}.dkr.ecr.${var.region}.amazonaws.com/${var.ecs_service_name}:${var.service_tag}"
  ecs_service_name      = var.ecs_service_name
  memory                = var.memory
  spring_profile        = var.spring_profile

  ecs_alb_listener_arn = module.platform.ecs_alb_listener_arn
  ecs_cluster_name     = module.platform.ecs_cluster_name
  ecs_domain_name      = module.platform.ecs_domain_name
  region               = var.region
  ecs_public_subnets   = module.networking.public_subnet_ids
  vpc_id               = module.networking.vpc_id
}
