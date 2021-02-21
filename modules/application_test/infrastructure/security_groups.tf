resource "aws_security_group" "app_security_group" {
  name        = "${var.ecs_service_name}-SG"
  description = "Security group for springbootapp to communicate in and out"
  vpc_id      = var.vpc_id

  ingress  {
    from_port = 8080
    protocol  = "TCP"
    to_port   = 8080
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecs_service_name}-SG"
  }
}
