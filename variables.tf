variable "region" {
  description = "ap-northeast-2"
}

variable "environment" {
  description = "The Deployment environment"
}

// Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

// Platform
variable "ecs_domain_name" {
  type        = string
  description = "Your platform domain name"
}

// Application
variable "ecs_service_name" {}
variable "docker_container_port" {}
variable "desired_task_number" {}
variable "spring_profile" {
  default = "default"
}
variable "memory" {}
variable "aws_account" {}
variable "service_tag" {
  description = "docker image version tag"
}
