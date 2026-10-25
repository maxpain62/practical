#resource "aws_instance" "control-plane" {
#  count = var.instance_count
#
#  instance_type        = var.instance_type
#  ami                  = var.ami
#  key_name             = var.key_name
#  user_data            = file("control-plane-user-data.sh")
#  security_groups      = ["launch-wizard-1"]
#  iam_instance_profile = "adminrole"
#
#  tags = {
#    Name         = "controlplane-${count.index}"
#    controlplane = "true"
#    createdby    = "terraform"
#    env          = "dev"
#  }
#}