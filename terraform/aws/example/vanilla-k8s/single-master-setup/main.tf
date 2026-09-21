resource "aws_instance" "kubernetes_master" {
    instance_type = "t3a.medium"
    security_groups = [ "launch-wizard-1" ]
    key_name = "dpp-key"
    ami = "ami-02d26659fd82cf299" 
    user_data = file("user_data.sh")
    instance_market_options {
        market_type = "spot"
    }

    tags = {
      Name = "master"
      env = "dev"
      app = "kubernetes"
      controlplane = true
    }
}

data "aws_ami" "ubuntu" {
  filter {
    name = "image-id"
    values = [ "ami-001e7cc215773c7fb" ]
  }
}

resource "aws_launch_template" "node_lt" {
  name = "node_lt"
  image_id = "ami-001e7cc215773c7fb"
  instance_type = "t3a.medium"
  key_name = "dpp-key"
  security_group_names = [ "launch-wizard-1" ]
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
      Name = "node"
      env = "dev"
      app = "kubernetes"
      controlplane = false
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "node-volume"
      env = "dev"
      app = "kubernetes"
      controlplane = false
    }
  }
  depends_on = [ aws_instance.kubernetes_master ]
}

resource "aws_autoscaling_group" "node_asg" {
  name = "node-asg"
  max_size = 3
  min_size = 2
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  launch_template {
    id = aws_launch_template.node_lt.id
    version = "$Latest"
  }
  depends_on = [ aws_launch_template.node_lt ]
}

output "public_ip" {
  value = aws_instance.kubernetes_master.public_ip
}