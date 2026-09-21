module "ec2-zenpharma" {
  source = "../module/ec2"
  ec2-count = 1
  ec2-name = "zenpharma"
  instance_type = "t3.micro"
  user_data = file("user-data.sh")
  iam_instance_profile = "adminrole"
}