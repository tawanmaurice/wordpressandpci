########################################
# Application Load Balancer + Listeners
########################################

resource "aws_lb" "app1_alb" {
  name               = "app1-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [
    aws_security_group.app1-sg02-LB01.id
  ]

  subnets = [
    aws_subnet.public-us-east-1a.id,
    aws_subnet.public-us-east-1b.id,
    aws_subnet.public-us-east-1c.id,
  ]

  tags = {
    Name    = "app1-alb"
    Owner   = "Tawan"
    Planet  = "terraform-training"
    Service = "application1"
  }
}

# HTTP listener: redirect to HTTPS
resource "aws_lb_listener" "app1_http" {
  load_balancer_arn = aws_lb.app1_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener: terminate TLS and forward to target group
resource "aws_lb_listener" "app1_https" {
  load_balancer_arn = aws_lb.app1_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate_validation.app_cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1_tg.arn
  }
}

output "lb_dns_name" {
  value = aws_lb.app1_alb.dns_name
}
