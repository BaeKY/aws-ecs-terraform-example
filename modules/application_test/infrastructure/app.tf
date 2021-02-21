data "template_file" "ecs_task_definition_template" {
  template = file("${path.module}/task_definition.json")

  vars = {
    task_definition_name  = var.ecs_service_name
    ecs_service_name      = var.ecs_service_name
    docker_image_url      = var.docker_image_url
    memory                = var.memory
    docker_container_port = var.docker_container_port
    spring_profile        = var.spring_profile
    region                = var.region
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.ecs_cluster_name
}
resource "aws_ecs_task_definition" "springbootapp-task-definition" {

  container_definitions    = data.template_file.ecs_task_definition_template.rendered
  family                   = var.ecs_service_name
  cpu                      = 512
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.fargate_iam_role.arn
  task_role_arn            = aws_iam_role.fargate_iam_role.arn
}

resource "aws_iam_role" "fargate_iam_role" {
  name               = "${var.ecs_service_name}-IAM-Role"
  assume_role_policy = file("${path.module}/iam/fargate_iam_role.json")
}

resource "aws_iam_role_policy" "fargate_iam_role_policy" {
  name = "${var.ecs_service_name}-IAM-Role-Policy"
  role = aws_iam_role.fargate_iam_role.id

  policy = file("${path.module}/iam/fargate_iam_role_policy.json")

}

resource "aws_alb_target_group" "ecs_app_target_group" {
  name        = "${var.ecs_service_name}-TG"
  port        = var.docker_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 30
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }

  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  task_definition = var.ecs_service_name
  desired_count   = var.desired_task_number
  cluster         = var.ecs_cluster_name
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.ecs_public_subnets
    security_groups = [
    aws_security_group.app_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = var.ecs_service_name
    container_port   = var.docker_container_port
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }

}

resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
  listener_arn = var.ecs_alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }

  condition {
    host_header {
      values = [
      "${lower(var.ecs_service_name)}.${var.ecs_domain_name}"]
    }
  }
}

resource "aws_cloudwatch_log_group" "springbootapp_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}

