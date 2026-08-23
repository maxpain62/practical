resource "aws_autoscaling_group" "k8s_asg" {
  name = "k8s-asg"
  max_size = 2
  min_size = 2
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  launch_template {
    id = aws_launch_template.k8s_lt.id
    version = "$Latest"
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