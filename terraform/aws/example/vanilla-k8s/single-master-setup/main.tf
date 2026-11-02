resource "aws_security_group" "kubernetes_sg" {
  description = "Kubernetes Security Group"
  name        = "kubernetes_sg"

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
    description = "Kubernetes API Server access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "kubernetes_sg"
    env        = "dev"
    app        = "kubernetes"
    created_by = "terraform"
  }
}


resource "aws_instance" "controlplane" {
  instance_type   = "t3.medium"
  security_groups = [aws_security_group.kubernetes_sg.name]
  key_name        = "dpp-key"
  ami             = "ami-02d26659fd82cf299"
  user_data       = file("user_data.sh")

  tags = {
    Name         = "controlplane"
    env          = "dev"
    app          = "kubernetes"
    controlplane = true
    created_by   = "terraform"
  }
}


resource "aws_launch_template" "node_lt" {
  name                 = "node_lt"
  image_id             = "ami-02d26659fd82cf299"
  instance_type        = "t3.medium"
  key_name             = "dpp-key"
  security_group_names = ["launch-wizard-1"]

  instance_market_options {
    market_type = "spot"
  }

  block_device_mappings {
    device_name = data.aws_ami.ubuntu.root_device_name
    ebs {
      volume_size = 20
    }
  }

  user_data = filebase64("node_user_data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name         = "node"
      env          = "dev"
      app          = "kubernetes"
      controlplane = false
      created_by   = "terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name         = "node-volume"
      env          = "dev"
      app          = "kubernetes"
      controlplane = false
      created_by   = "terraform"
    }
  }
  depends_on = [aws_instance.kubernetes_master]
}


resource "aws_autoscaling_group" "node_asg" {
  name               = "node-asg"
  max_size           = 3
  min_size           = 2
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  launch_template {
    id      = aws_launch_template.node_lt.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.node_lt]
}


output "public_ip" {
  value = aws_instance.kubernetes_master.public_ip
}