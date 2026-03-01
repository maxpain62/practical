resource "aws_eks_addon" "addons" {
  count        = length(var.addon_list)
  cluster_name = aws_eks_cluster.demo_cluster.name
  addon_name   = element(var.addon_list, count.index)
  depends_on   = [aws_eks_node_group.demo_nodegroup]
}


resource "aws_iam_openid_connect_provider" "ebs_csi_oidcprovider" {
  url            = aws_eks_cluster.demo_cluster.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]
  depends_on     = [aws_eks_node_group.demo_nodegroup]
}

#create assume role policy
data "aws_iam_policy_document" "AmazonEKS_EBS_CSI_DriverRole_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.ebs_csi_oidcprovider.arn]
    }
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${replace(aws_iam_openid_connect_provider.ebs_csi_oidcprovider.url, "https://", "")}:aud"
    }
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
      variable = "${replace(aws_iam_openid_connect_provider.ebs_csi_oidcprovider.url, "https://", "")}:sub"
    }
  }
  depends_on = [aws_iam_openid_connect_provider.ebs_csi_oidcprovider]
}

#create role and assume policy
resource "aws_iam_role" "AmazonEKS_EBS_CSI_DriverRole" {
  name               = "AmazonEKS_EBS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.AmazonEKS_EBS_CSI_DriverRole_policy.json
  depends_on         = [data.aws_iam_policy_document.AmazonEKS_EBS_CSI_DriverRole_policy]
}

#attache policy to role
resource "aws_iam_role_policy_attachment" "AmazonEKS_EBS_CSI_DriverRole_policy_attachment" {
  role       = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  depends_on = [aws_iam_role.AmazonEKS_EBS_CSI_DriverRole]
}

#installation of ebs csi addon
resource "aws_eks_addon" "ebc_csi_addon" {
  cluster_name             = aws_eks_cluster.demo_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.arn
  depends_on               = [aws_eks_node_group.demo_nodegroup, aws_iam_role_policy_attachment.AmazonEKS_EBS_CSI_DriverRole_policy_attachment]
}