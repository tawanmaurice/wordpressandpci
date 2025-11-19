data "aws_ami" "amazon_linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["137112412989"]
}

resource "aws_launch_template" "app1_lt" {
  name_prefix   = "app1-lt"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
    #!/bin/bash

    DB_NAME="${var.db_name}"
    DB_USER="${var.db_username}"
    DB_PASSWORD="${var.db_password}"
    DB_HOST="${aws_db_instance.wp.address}"

    yum update -y
    yum install -y httpd php php-mysqlnd php-fpm php-json php-xml php-mbstring php-gd tar curl

    systemctl enable httpd
    systemctl start httpd

    cd /tmp
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz

    rm -rf /var/www/html/*
    cp -r /tmp/wordpress/* /var/www/html/

    chown -R apache:apache /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \\;
    find /var/www/html -type f -exec chmod 644 {} \\;

    cd /var/www/html
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$${DB_NAME}/" wp-config.php
    sed -i "s/username_here/$${DB_USER}/" wp-config.php
    sed -i "s/password_here/$${DB_PASSWORD}/" wp-config.php
    sed -i "s/localhost/$${DB_HOST}/" wp-config.php

    systemctl restart httpd
EOF
  )
}
