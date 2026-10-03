resource "aws_db_subnet_group" "this" {
  name       = "${lower(var.namespace)}-wordpress-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.namespace}-wordpress-db-subnets"
  }
}

resource "aws_db_instance" "wordpress" {
  identifier = "${lower(var.namespace)}-wordpress-db"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false
  multi_az               = true

  backup_retention_period = 1
  apply_immediately       = true

  skip_final_snapshot      = true
  delete_automated_backups = true
  deletion_protection      = false

  tags = {
    Name = "${var.namespace}-wordpress-db"
  }
}
