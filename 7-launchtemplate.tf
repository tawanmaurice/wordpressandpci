########################################
# Launch Template for app servers
########################################

locals {
  wp_site_url = "https://site.tawanperry.top"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "app1_lt" {
  name_prefix   = "app1-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  # Security group for EC2 instances (already defined in 6-sg01-all.tf)
  vpc_security_group_ids = [
    aws_security_group.app1-sg01-servers.id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -xe

    # Update system
    dnf update -y

    # Install Apache (httpd)
    dnf install -y httpd

    systemctl enable httpd
    systemctl start httpd

    # Simple HTML landing page showing our PCI/WordPress test site info
    cat <<HTML >/var/www/html/index.html
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <title>WordPress & PCI Test - ${local.wp_site_url}</title>
      </head>
      <body style="font-family: Arial, sans-serif; background: #0b1120; color: #e5e7eb; text-align: center; padding-top: 60px;">
        <h1 style="font-size: 2.5rem; margin-bottom: 1rem;">Welcome to ${local.wp_site_url}</h1>
        <p style="font-size: 1.2rem; max-width: 640px; margin: 0 auto 1.5rem;">
          This AWS environment is designed for a future WordPress deployment with
          PCI-style hardening and security scans.
        </p>
        <p style="font-size: 1rem; color: #9ca3af;">
          Deployed via Terraform using a Launch Template, Auto Scaling Group, ALB,
          ACM certificate, and Route53.
        </p>
      </body>
    </html>
    HTML

  EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "app1-launch-template"
    Owner   = "Tawan"
    Planet  = "terraform-training"
    Service = "application1"
  }
}
