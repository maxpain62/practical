# Configure AWS Load Balancer Controller with Helm

## Step 1: Create IAM Role using eksctl 
1. Download an IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf.
```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json
```

2. Create an IAM policy using the policy downloaded in the previous step
```
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
```

3. Replace the values for cluster name, region code, and account ID.
```
eksctl create iamserviceaccount \
    --cluster=<cluster-name> \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region <aws-region-code> \
    --approve
```

### If IAM Role creation is successful you will get following message
```
2026-06-26 06:29:49 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
2026-06-26 06:29:49 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2026-06-26 06:29:49 [ℹ]  1 task: { 
    2 sequential sub-tasks: { 
        create IAM role for serviceaccount "kube-system/aws-load-balancer-controller",
        create serviceaccount "kube-system/aws-load-balancer-controller",
    } }2026-06-26 06:29:49 [ℹ]  building iamserviceaccount stack "eksctl-demo-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2026-06-26 06:29:49 [ℹ]  deploying stack "eksctl-demo-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2026-06-26 06:29:49 [ℹ]  waiting for CloudFormation stack "eksctl-demo-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2026-06-26 06:30:19 [ℹ]  waiting for CloudFormation stack "eksctl-demo-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2026-06-26 06:30:19 [ℹ]  created serviceaccount "kube-system/aws-load-balancer-controller"
``` 

Verify IAM Role creation with below command 
```
kubectl get sa aws-load-balancer-controller -n kube-system
```
Output:-
```
NAME                           SECRETS   AGE
aws-load-balancer-controller   0         34s
```

### Troubleshooting steps - If you receive following message, then IAM role is not created
```
2026-06-26 06:28:16 [ℹ]  1 existing iamserviceaccount(s) (kube-system/aws-load-balancer-controller) will be excluded
2026-06-26 06:28:16 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was excluded (based on the include/exclude rules)
2026-06-26 06:28:16 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2026-06-26 06:28:16 [ℹ]  no tasks
```

1. In case IAM role is not created then run below command and wait for 5 minutes
```
eksctl delete iamserviceaccount --cluster=demo-cluster --namespace=kube-system --name=aws-load-balancer-controller --region ap-south-1
```

- Output :-
```
2026-06-26 06:29:12 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
2026-06-26 06:29:13 [ℹ]  1 task: { 
    2 sequential sub-tasks: { 
        delete IAM role for serviceaccount "kube-system/aws-load-balancer-controller" [async],
        delete serviceaccount "kube-system/aws-load-balancer-controller",
    } }2026-06-26 06:29:13 [ℹ]  will delete stack "eksctl-demo-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2026-06-26 06:29:13 [ℹ]  serviceaccount "kube-system/aws-load-balancer-controller" was already deleted
```

2. After 5 minutes run following command to create IAM role
```
eksctl create iamserviceaccount \
    --cluster=<cluster-name> \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region <aws-region-code> \
    --approve
```

3. Verify IAM Role creation with below command 
```
kubectl get sa aws-load-balancer-controller -n kube-system
```
- Output:-
```
NAME                           SECRETS   AGE
aws-load-balancer-controller   0         34s
```

### If IAM Role is still not created, manually create it with following steps

- Download an IAM policy for the AWS Load Balancer Controller that allows it to make calls to AWS APIs on your behalf.
```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json
```

- Create an IAM policy using the policy downloaded in the previous step
```
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
```


- notedown alphanumaric code from output of below command. eg - 19967F41FCED08E1FC433A772EF06883
```
aws iam list-open-id-connect-providers --output text
```
- Create file __*Test-Role-Trust-Policy.json*__, and enter below code

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/<alphanumaric code>"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.ap-south-1.amazonaws.com/id/<alphanumaric code>:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller",
                    "oidc.eks.ap-south-1.amazonaws.com/id/<alphanumaric code>:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```

- Create Role
```
aws iam create-role --role-name Test-Role --assume-role-policy-document file://Test-Role-Trust-Policy.json

```
- Attach IAM policy to above role
```
aws iam attach-role-policy --policy-arn <policy arn> --role-name Test-Role
```

- create service account with following code. 
```
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/Test-Role
  name: aws-load-balancer-controller
  namespace: kube-system
```

## Step 2: Install AWS Load Balancer Controller

1. Add the eks-charts Helm chart repository. AWS maintains this repository on GitHub.
```
helm repo add eks https://aws.github.io/eks-charts
```
2. Update your local repo to make sure that you have the most recent charts.
```
helm repo update eks
```

3. Install the AWS Load Balancer Controller.
```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set region=region-code
  --set vpcId=vpc-xxxxxxxx
  --set serviceAccount.name=aws-load-balancer-controller \
  --version 1.14.0
```

## Step 3: Verify that the controller is installed
1. Verify that the controller is installed.
```
kubectl get deployment -n kube-system aws-load-balancer-controller
```
An example output is as follows.
```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           84s
```

reference - https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html