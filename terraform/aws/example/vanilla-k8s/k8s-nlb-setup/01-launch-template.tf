resource "aws_launch_template" "k8s_lt" {
  name = "k8s_lt"
  image_id = "ami-02d26659fd82cf299"
  instance_type = "t3a.medium"
  key_name = "dpp-key"
  security_group_names = [ "launch-wizard-1" ]
  instance_market_options {
    market_type = "spot"
  }

  user_data = filebase64("user_data_base64")
  tag_specifications {
    resource_type = "instance"
    tags = {
      env = "dev"
      Name = "master-node"
    }
  }
}

resource "aws_launch_template" "node_lt" {
  name = "node_lt"
  image_id = "ami-02d26659fd82cf299"
  instance_type = "t3a.medium"
  key_name = "dpp-key"
  security_group_names = [ "launch-wizard-1" ]
  instance_market_options {
    market_type = "spot"
  }

  user_data = filebase64("user-data-node-base64")
  tag_specifications {
    resource_type = "instance"
    tags = {
      env = "dev"
      Name = "node"
    }
  }
}