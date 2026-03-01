terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_launch_template" "demo_launch_template" {
  name          = "demo_launch_template"
  key_name      = "dpp-key"
  instance_type = "t3.micro"
  image_id      = "ami-02d26659fd82cf299"
  #block_device_mappings {
  #  device_name = "/dev/sdb"
  #  ebs {
  #    volume_size = 1
  #    volume_type = "gp3"
  #  }
  #}
  tag_specifications {
    resource_type = "instance"
    tags = {
      env = "dev"
    }
  }
}

resource "aws_instance" "demo_launch_template_instance" {
  security_groups = ["launch-wizard-1"]
  launch_template {
    id      = aws_launch_template.demo_launch_template.id
    version = "$Latest"
  }
}

output "public_ip" {
  value = aws_instance.demo_launch_template_instance.public_ip
}