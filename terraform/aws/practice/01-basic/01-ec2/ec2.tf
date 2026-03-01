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

resource "aws_instance" "tf_demo_ec2" {
  instance_type = "t2.micro"
  ami = "ami-02d26659fd82cf299"
  security_groups = [ "launch-wizard-1" ]
  key_name = "dpp-key"
}