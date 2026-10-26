resource "aws_lb_target_group" "k8s" {
  name     = "k8s-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = "vpc-0d3a50be006d42f8e"

  health_check {
    enabled           = true
    healthy_threshold = 2
    interval          = 60
    protocol          = "TCP"
  }
}

resource "aws_lb_listener" "k8s_listener" {
  load_balancer_arn = aws_lb.k8s_lb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_tg.arn
  }
}

resource "aws_lb" "k8s_lb" {
  name               = "k8s"
  internal           = false
  load_balancer_type = "network"
  security_groups    = ["sg-01dc33cd3198b94bd"]
  subnets            = ["subnet-0f35e939a90a45918", "subnet-0d5e6fbd8f73e83ae", "subnet-012c74198ecc303e8"]

  tags = {
    Name = "k8s_lb"
    env  = "dev"
  }
}