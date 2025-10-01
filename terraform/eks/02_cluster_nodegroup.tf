resource "aws_launch_template" "eks_demo_launch_template" {
  name          = "eks_demo_launch_template"
  key_name      = "dpp-key"
  instance_type = "t3a.medium"
  #image_id      = "ami-02d26659fd82cf299"
  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_size = 8
      volume_type = "gp3"
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      env = "dev"
    }
  }
}

resource "aws_eks_cluster" "demo_cluster" {
  name     = "demo_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.32"

  upgrade_policy {
    support_type = "STANDARD"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.subnet_id
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_iam_role_policy_attachment.cluster_role_policy_attachment
  ]

  tags = {
    env = "dev"
  }
}

resource "aws_eks_node_group" "demo_nodegroup" {
  cluster_name    = aws_eks_cluster.demo_cluster.name
  node_group_name = "demo_nodegroup"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "SPOT"
  #disk_size       = 20
  #instance_types  = ["t3a.medium"]
  subnet_ids      = var.subnet_id
  
   launch_template {
    id      = aws_launch_template.eks_demo_launch_template.id
    version = "$Default"
  }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }

  labels = {
    speed = "fast"
    instancetype = "mseries"
  }
  tags = {
    env = "dev"
    speed = "fast"
  }

  depends_on = [
    aws_eks_cluster.demo_cluster,
    aws_iam_role_policy_attachment.eks_nodegroup_role_policy_attachment
  ]
}

resource "aws_eks_node_group" "demo_nodegroup_rseries" {
  cluster_name    = aws_eks_cluster.demo_cluster.name
  node_group_name = "demo_nodegroup_rseries"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "SPOT"
  disk_size       = 20
  instance_types  = ["t3a.medium"]
  subnet_ids      = var.subnet_id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }
  update_config {
    max_unavailable = 1
  }

  labels = {
    instancetype = "rseries"
  }
  tags = {
    env = "dev"
    speed = "slow"
  }

  depends_on = [
    aws_eks_cluster.demo_cluster,
    aws_iam_role_policy_attachment.eks_nodegroup_role_policy_attachment
  ]
}

output "cluster_name" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.demo_cluster.name}"
}