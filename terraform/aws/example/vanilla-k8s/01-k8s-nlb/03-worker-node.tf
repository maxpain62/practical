resource "aws_launch_template" "node_lt" {
  name                 = "node_lt"
  image_id             = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_group_names = ["launch-wizard-1"]
  instance_market_options {
    market_type = "spot"
  }

  user_data = filebase64("worker-node.sh")
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      env  = "dev"
      Name = "node"
    }
  }
  depends_on = [ aws_instance.control-plane ]
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
}