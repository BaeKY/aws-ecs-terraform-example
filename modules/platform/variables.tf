variable "environment" {
  description = "The Deployment environment"
}

variable "region" {
  description = "AWS region"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "ecs_cluster_name" {
  description = "Fargate cluster name"
}

variable "internet_cidr_block" {
  default     = "0.0.0.0/0"
  description = "cidr for internet"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "public subnets"
}

variable "ecs_domain_name" {
  type        = string
  description = "Your domain"
}
