resource "aws_lb" "demo_alb" {
  name = "demo-alb"
  load_balancer_type = "application"
  security_groups = ["sg-01dc33cd3198b94bd"]
  subnets = [ "subnet-0f35e939a90a45918", "subnet-012c74198ecc303e8" ]
  tags = {
    env = "dev"
  }
}

resource "aws_lb_listener" "demo_lb_listner" {
  load_balancer_arn = aws_lb.demo_alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:ap-south-1:134448505602:certificate/ea0de3ec-263d-4a35-a874-700347c4da60"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.demo_tg.arn
  }
}
