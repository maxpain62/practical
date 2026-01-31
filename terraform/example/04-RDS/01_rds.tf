resource "aws_db_instance" "eos_rds" {
  allocated_storage = 20
  max_allocated_storage = 25
  db_name = "eos_db"
  engine  = "mariadb"
  engine_version = "10.11.15"
  instance_class = "db.t3.micro"
  backup_retention_period = 0
  availability_zone = "ap-south-1a"
  username = "eosadmin"
  password = "eosadmin"
  skip_final_snapshot  = true
}