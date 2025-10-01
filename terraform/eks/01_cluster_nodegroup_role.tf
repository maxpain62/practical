resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "eks.amazonaws.com"
          },
          "Action" : [
            "sts:AssumeRole",
            "sts:TagSession"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
  count      = length(var.cluster_policy_arn)
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = element(var.cluster_policy_arn, count.index)
  depends_on = [ aws_iam_role.eks_cluster_role ]
}


resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eks_nodegroup_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_role_policy_attachment" {
  count      = length(var.nodegroup_policy_arn)
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = element(var.nodegroup_policy_arn, count.index)
  depends_on = [ aws_iam_role.eks_nodegroup_role ]
}

#Below reqource entries will give access to user eos_admin with AmazonEKSClusterAdminPolicy to cluster
resource "aws_eks_access_entry" "eks_access_entry" {
  cluster_name      = aws_eks_cluster.demo_cluster.name
  principal_arn     = "arn:aws:iam::134448505602:user/aws-cli"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_access_policy_association" {
  cluster_name  = aws_eks_cluster.demo_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::134448505602:user/aws-cli"
  access_scope {
    type       = "cluster"
  }
}