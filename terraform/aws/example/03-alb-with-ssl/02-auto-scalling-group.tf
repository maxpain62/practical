resource "aws_autoscaling_group" "demo_asg" {
  name = "demo-asg"
  max_size = 2
  min_size = 1
  availability_zones = ["ap-south-1a", "ap-south-1b"]
  launch_template {
    id = aws_launch_template.demo_lt.id
    version = "$Latest"
  }
}