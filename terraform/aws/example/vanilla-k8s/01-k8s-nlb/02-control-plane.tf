resource "aws_instance" "control-plane" {
  count = var.instance_count

  instance_type        = var.instance_type
  ami                  = var.ami
  key_name             = var.key_name
  user_data            = file("control-plane.sh")
  security_groups      = ["launch-wizard-1"]
  iam_instance_profile = "adminrole"

  tags = {
    Name         = "controlplane-${count.index}"
    controlplane = "true"
    createdby    = "terraform"
    env          = "dev"
  }

  depends_on = [ aws_lb.k8s ]
}

output "control_plane_public_ip" {
  value = aws_instance.control-plane.*.public_ip
}