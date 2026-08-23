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

output "public_ip" {
  value = aws_instance.kubernetes_master.public_ip
}

resource "aws_launch_template" "node_lt" {
  name = "node_lt"
  image_id = "ami-02d26659fd82cf299"
  instance_type = "t3a.medium"
  key_name = "dpp-key"
  security_group_names = [ "launch-wizard-1" ]
  instance_market_options {
    market_type = "spot"
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
}