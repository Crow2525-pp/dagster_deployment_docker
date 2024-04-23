# Create a DB Subnet Group
resource "aws_db_subnet_group" "dagster_db_subnet_group" {
  name       = "dagster-db-subnet-group"
  subnet_ids = [aws_subnet.dagster_subnet.id,aws_subnet.dagster_subnet_2.id]

  tags = {
    Name = "Dagster DB Subnet Group"
  }
}

# Create an RDS instance
resource "aws_db_instance" "dagster_postgres_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  db_name              = "postgres_db"
  username             = "postgres_user"
  password             = "postgres_password"
  parameter_group_name = "default.postgres15"
  db_subnet_group_name = aws_db_subnet_group.dagster_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.dagster_sg.id]
  multi_az             = false
  publicly_accessible = true
  deletion_protection = false
  skip_final_snapshot  = true
}

# Outputs
output "db_instance_endpoint" {
  value = aws_db_instance.dagster_postgres_db.endpoint
}

output "db_instance_status" {
  value = aws_db_instance.dagster_postgres_db.status
}