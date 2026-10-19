resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "sg for demo host"

  ingress {
    description = "SSH access for demo host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  name                        = "demo"
  key_name                    = "dpp-key"
  ami                         = "ami-02d26659fd82cf299"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  create_security_group       = false
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
}