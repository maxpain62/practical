variable "cluster_policy_arn" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  ]
}

variable "nodegroup_policy_arn" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

variable "addon_list" {
  type = list(string)
  default = [
    "eks-node-monitoring-agent",
    "kube-proxy",
    "eks-pod-identity-agent",
    "coredns",
    "external-dns",
    "metrics-server"
  ]
}

variable "subnet_id" {
  type = list(string)
  default = [
    "subnet-0f35e939a90a45918",
    "subnet-0d5e6fbd8f73e83ae",
    "subnet-012c74198ecc303e8"
  ]
}