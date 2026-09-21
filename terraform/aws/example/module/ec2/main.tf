resource "aws_instance" "ec2" {
  count = var.ec2-count
  ami = var.ami
  instance_type = var.instance_type
  security_groups = var.security_groups
  key_name = var.key_name
  user_data = var.user_data
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "${var.ec2-name}-${count.index}"
    env = "dev"
  }
}