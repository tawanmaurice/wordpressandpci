resource "aws_lb_target_group" "app1_tg" {
  name        = "app1-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.app1.id

  # Health check – match what AWS already has
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }

  # Stickiness block to match existing target group
  stickiness {
    enabled         = false
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  tags = {
    Name    = "App1TargetGroup"
    Owner   = "Tawan"
    Project = "terraform-training"
    Service = "dev"
  }
}
