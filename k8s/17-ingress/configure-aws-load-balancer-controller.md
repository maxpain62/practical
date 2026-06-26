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