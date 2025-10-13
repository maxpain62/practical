# Grant EKS cluster access to EC2 with IAM role

### Prerequisits -

1. Working EKS cluster
2. EC2 instance
3. aws cli and kubectl installed on instance

#### Step 1 - Create and configure IAM role.

- Select AWS service from Trusted entity type.
- From usecase select EC2.
- In add permission tab select suitable policy. I have created custome policy like below :-

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "eks:ListAccessEntries",
                "eks:ListAccessPolicies",
                "eks:ListAddons",
                "eks:ListAssociatedAccessPolicies",
                "eks:ListClusters",
                "eks:ListEksAnywhereSubscriptions",
                "eks:ListFargateProfiles",
                "eks:ListIdentityProviderConfigs",
                "eks:ListInsights",
                "eks:ListNodegroups",
                "eks:ListPodIdentityAssociations",
                "eks:ListUpdates",
                "eks:AccessKubernetesApi",
                "eks:DescribeAccessEntry",
                "eks:DescribeAddon",
                "eks:DescribeAddonConfiguration",
                "eks:DescribeAddonVersions",
                "eks:DescribeCluster",
                "eks:DescribeClusterVersions",
                "eks:DescribeEksAnywhereSubscription",
                "eks:DescribeFargateProfile",
                "eks:DescribeIdentityProviderConfig",
                "eks:DescribeInsight",
                "eks:DescribeInsightsRefresh",
                "eks:DescribeNodegroup",
                "eks:DescribePodIdentityAssociation",
                "eks:DescribeUpdate",
                "eks:ListDashboardData",
                "eks:ListDashboardResources",
                "eks:ListTagsForResource"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

#### Step 2 - Attach IAM role to EC2 instance.

#### Step 3 - Create cluster role.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: readonly-cluster-role
rules:
  - apiGroups:
      - "*"
    resources:
      - "*"
    verbs:
      - get
      - list
      - watch
```

#### Step 4 - Create cluster role binding.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: readonly-cluster-role-binding
subjects:
  - kind: Group
    name: readonly-group
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: readonly-cluster-role
  apiGroup: rbac.authorization.k8s.io
```

#### Step 5 - Edit configmap aws-auth

- Run command _**kubectl edit cm aws-auth -n kube-system**_ and insert below yaml code snippet

```
    - rolearn: arn:aws:iam::134448505602:role/EKSClusterReadOnlyRole
      groups:
        - readonly-group
      username: EKSClusterReadOnlyRole
```

#### Step 6 - Create cluster config file with

- Run command _**aws eks update-kubeconfig --name demo_cluster --region aws_region**_
