terraform {
  required_providers {
    aws = {
        version = "~>6.0"
        source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "simple_ec2" {
  instance_type = "t3.medium"
  ami = "ami-02d26659fd82cf299"
  security_groups = ["launch-wizard-1"]
  key_name = "dpp-key"
  iam_instance_profile = "adminrole"
  instance_market_options {
    market_type = "spot"
  }
  user_data = file("terraform_installation.sh")
  tags = {
    Name = "simple_ec2"
    env = "dev"
  }
}

output "simple_ec2_public_ip" {
  value = aws_instance.simple_ec2.public_ip
}