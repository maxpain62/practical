# How to grant EKS cluster access to aws IAM user

### Step 1 - Execute below command:-

kubectl edit configmap aws-auth -n kube-system.

Editor will be opened and below yaml file will be visible

```
apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<Account ID>:role/eks_nodegroup_role
      groups:
      - system:bootstrappers
      - system:nodes
      username: system:node:{{EC2PrivateDNSName}}
kind: ConfigMap
metadata:
  creationTimestamp: "2025-10-12T12:23:10Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "1036"
  uid: 67e28050-d61c-4453-b247-7bb821c4b90c

```

### Step 2 - Insert code snippet as below after line _**username: system:node:{{EC2PrivateDNSName}}**_

```
  mapUsers: |
    - userarn: arn:aws:iam::<Account ID>:user/john-devops
      username: john-devops
      groups:
        - system:masters
```

#### Note - we need to change some values in above yaml code

1. Account ID replace this with your AWS account ID
2. john-devops replace this value with IAM user name which you have created in AWS IAM console
3. Save and close text editor

### Step 3 - Grant EKS access

- Here you can add user to a group and add permissions to that group with predefined policies or inline policies.

- Or directly add attach policy to individual user by attaching predefined policies or inline policiy.

refer below sample policy :-

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        }
    ]
}
```

### Step 4 - Create security credential for IAM user and run aws configure.

- Create security credentials for IAM user.
- Make sure aws cli and kubectl is installed
- Run _**aws configure**_ command
- Once aws credentials are saved then run command _**aws eks update-kubeconfig --name demo_cluster**_ replace _**demo_cluster**_ with name of your eks cluster
- confirm if your are able to access kubernetes clster _**kubectl get po**_
