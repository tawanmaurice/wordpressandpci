resource "aws_launch_template" "app1_LT" {
  name_prefix   = "wp-pci-lt-"
  image_id      = "ami-0cae6d6fe6048ca2c" # Amazon Linux 2023 (x86)
  instance_type = "t2.micro"

  # Use the security group that allows HTTP from the load balancer / internet
  vpc_security_group_ids = [aws_security_group.app1-sg01-servers.id]

  # Optional: use your existing key pair name if you want SSH access
  # key_name = "MyLinuxBox"

  user_data = base64encode(<<-EOF
    #!/bin/bash

    # Subdomain this stack is intended to serve via Route 53
    DOMAIN_NAME="wp-pci.tawanperry.top"

    # Basic LAMP-ish stack: Apache + PHP (WordPress-ready)
    dnf update -y
    dnf install -y httpd php php-mysqlnd

    systemctl enable httpd
    systemctl start httpd

    # Simple placeholder site for the WordPress + PCI project
    cat <<HTML > /var/www/html/index.html
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8" />
      <title>WordPress + PCI Demo - $DOMAIN_NAME</title>
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <style>
        body {
          margin: 0;
          font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
          background: #020617;
          color: #e5e7eb;
          display: flex;
          align-items: center;
          justify-content: center;
          min-height: 100vh;
        }
        .card {
          padding: 24px 28px;
          border-radius: 14px;
          border: 1px solid #334155;
          background: #020617;
          box-shadow: 0 24px 50px rgba(0,0,0,0.6);
          max-width: 640px;
        }
        h1 { margin: 0 0 8px; font-size: 1.9rem; }
        h2 { margin: 0 0 16px; font-size: 1.1rem; color: #9ca3af; }
        p  { line-height: 1.5; font-size: 0.95rem; }
        .badge {
          display:inline-block;
          padding:4px 10px;
          border-radius:999px;
          border:1px solid #4b5563;
          font-size:0.75rem;
          margin-right:6px;
          margin-top:4px;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>WordPress + PCI Demo</h1>
        <h2>Hosted at: $DOMAIN_NAME</h2>

        <p>
          This stack is part of Tawan Perry’s
          <strong>WordPress + PCI Readiness</strong> project.
        </p>

        <p>
          <span class="badge">VPC</span>
          <span class="badge">Application Load Balancer</span>
          <span class="badge">Auto Scaling Group</span>
          <span class="badge">WordPress-ready LAMP</span>
        </p>

        <p style="margin-top:16px;font-size:0.9rem;color:#9ca3af;">
          Later, this placeholder page will be replaced by a full WordPress install
          with hardened settings, SSL, and PCI-friendly configuration.
        </p>
      </div>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "wp-pci-instance"
      Service = "dev"
      Owner   = "Tawan"
      Project = "wordpress-and-pci"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
