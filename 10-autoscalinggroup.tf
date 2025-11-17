########################################
# Auto Scaling Group
########################################

resource "aws_autoscaling_group" "app1_asg" {
  name                      = "app1-auto-scaling-group"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"

  # Put instances in the PRIVATE subnets (behind ALB, use NAT for outbound)
  vpc_zone_identifier = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id,
    aws_subnet.private-us-east-1c.id,
  ]

  target_group_arns = [
    aws_lb_target_group.app1_tg.arn
  ]

  launch_template {
    id      = aws_launch_template.app1_lt.id # <- fixed: app1_lt (not app1_LT)
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app1-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "Tawan"
    propagate_at_launch = true
  }

  tag {
    key                 = "Planet"
    value               = "terraform-training"
    propagate_at_launch = true
  }

  tag {
    key                 = "Service"
    value               = "application1"
    propagate_at_launch = true
  }
}

# (Optional) export ASG name
output "asg_name" {
  value = aws_autoscaling_group.app1_asg.name
}
