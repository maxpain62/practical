resource "aws_lb_target_group" "k8s_tg" {
  name = "k8s-tg"
  port = 6443 
  protocol = "TCP"
  vpc_id = "vpc-0d3a50be006d42f8e"

  health_check {
    enabled = true
    healthy_threshold = 2
    interval = 60
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "demo_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.k8s_asg.name
  lb_target_group_arn = aws_lb_target_group.k8s_tg.arn
}