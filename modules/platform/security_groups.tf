resource "aws_security_group" "ecs_alb_sg" {
  name        = "${var.environment}-ALB-SG"
  description = "Security group for alb to traffic ECS Cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.internet_cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = [var.internet_cidr_block]
  }

  tags = {
    Name        = "${var.environment}-ALB-SG"
    Environment = var.environment
  }
}
