resource "aws_launch_template" "demo_lt" {
  name = "demo-lt-tf"
  image_id = "ami-02d26659fd82cf299"
  instance_type = "t2.micro"
  key_name = "dpp-key"
  instance_market_options {
    market_type = "spot"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      env = "dev"
    }
  }
}