variable "region" {  }

variable "vpc_id" {  }

variable "ecs_cluster_name" { }

variable "ecs_public_subnets" {
  type = list(string)
}

variable "ecs_domain_name" {
  type = string
}

variable "ecs_alb_listener_arn" {

}

#application variables for task
variable "ecs_service_name" {
}

variable "docker_image_url" {
}

variable "memory" {
}

variable "docker_container_port" {
}

variable "spring_profile" {
}

variable "desired_task_number" {
}
