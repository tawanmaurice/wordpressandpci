resource "aws_security_group" "rds" {
  name        = "rds-mysql"
  description = "Allow MySQL access from WordPress app servers"
  vpc_id      = aws_vpc.app1.id

  ingress {
    description = "MySQL from app servers"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"

    security_groups = [
      aws_security_group.app1-sg01-servers.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-mysql"
  }
}
