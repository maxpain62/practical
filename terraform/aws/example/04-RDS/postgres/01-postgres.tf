resource "aws_db_instance" "eos_rds" {
  allocated_storage = 20
  max_allocated_storage = 25
  db_name = "mlflow"
  engine  = "postgres"
  engine_version = "18.3"
  instance_class = "db.t3.medium"
  backup_retention_period = 0
  availability_zone = "ap-south-1a"
  username = "postgres"
  password = "postgres"
  skip_final_snapshot  = true
  identifier = "mlflow"
  vpc_security_group_ids = ["sg-01dc33cd3198b94bd"]
  tags = {
    Name = "mlflow"
    env = "dev"
  }
}