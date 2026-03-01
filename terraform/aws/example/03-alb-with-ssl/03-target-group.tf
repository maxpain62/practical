resource "aws_lb_target_group" "demo_tg" {
  name = "demo-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-0d3a50be006d42f8e"

  health_check {
    healthy_threshold = 2
    interval = 10
    path = "/"
    port = "80"
    protocol = "HTTP"
    unhealthy_threshold = 3
  }
}

resource "aws_autoscaling_attachment" "demo_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.demo_asg.name
  lb_target_group_arn = aws_lb_target_group.demo_tg.arn
}