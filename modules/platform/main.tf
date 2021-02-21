data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_ecs_cluster" "fargate-cluster" {
  name = var.ecs_cluster_name
}

resource "aws_alb" "alb" {
  name            = "${var.ecs_cluster_name}-ecs-alb"
  internal        = false
  security_groups = [aws_security_group.ecs_alb_sg.id]
  subnets         = var.public_subnet_ids

  tags = {
    Name        = "${var.ecs_cluster_name}-alb"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "ecs_default_target_group" {
  name     = "${var.ecs_cluster_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name        = "${var.ecs_cluster_name}-tg"
    Environment = var.environment
  }
}

resource "aws_alb_listener" "ecs_alb_https_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.ecs_domain_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_default_target_group.arn
  }
  depends_on = [aws_alb_target_group.ecs_default_target_group]
}

resource "aws_route53_record" "ecs_load_balancer_record" {
  name    = "*.${var.ecs_domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.ecs_domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
  }
}

resource "aws_iam_role" "ecs_cluster_role" {
  name               = "${var.ecs_cluster_name}-iam-role"
  assume_role_policy = file("${path.module}/iam/ecs_cluster_role.json")
}

resource "aws_iam_role_policy" "ecs_cluster_policy" {
  name   = "${var.ecs_cluster_name}-IAM-Policy"
  role   = aws_iam_role.ecs_cluster_role.id
  policy = file("${path.module}/iam/ecs_cluster_policy.json")
}
