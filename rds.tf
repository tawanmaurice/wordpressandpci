resource "aws_db_subnet_group" "wp" {
  name = "wp-db-subnet-group"
  subnet_ids = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1c.id,
  ]

  tags = {
    Name = "wp-db-subnet-group"
  }
}

resource "aws_db_instance" "wp" {
  identifier        = "wp-db"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"

  # REMOVE db_name – AWS no longer accepts this for MySQL 8+
  # db_name                = var.db_name   ❌ REMOVE THIS

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.wp.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name = "wp-db"
  }
}
