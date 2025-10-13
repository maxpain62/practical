# How to grant EKS cluster access to Pod aws IAM user

### Prerequisits

1. AWS EKS cluster
2. Confirm _**OpenID Connect provider URL**_ is visible in overview page of EKS cluster

### Step 1 - create IAM role as below

1. Select _**Web identity**_ from _**Trusted entity type**_
2. From _**Web identity**_ drop down select OIDC provider which is associated with current eks cluster
3. Select _**sts.amazonaws.com**_ from audiance dropdown
4. click on add condition button
   - In key dropdown select OIDC provider
   - Condition - StringEquals
   - Value - _**system:serviceaccount:default:ServiceAccountName**_
   - Replace ServiceAccountName with name of service account you will create inside eks cluster with yaml file
5. Select policy you want to attach to your role. click next
6. Provide role name and click on create role.

### Step 2 - Associate IAM role with service account

Use below sample yaml code

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: service-account-with-iam-role
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::<Account ID>:role/ServiceAccountRoleName"
```

Note:

1. Replace **_Account ID_** with your AWS account id
2. Replace **_ServiceAccountRoleName_** with

### Step 3 - Create pod and associate with service account created in **step 2**

Use below sample yaml code

```
apiVersion: v1
kind: Pod
metadata:
  name: service-account-with-iam-role-pod
spec:
  serviceAccountName: service-account-with-iam-role
  containers:
    - name: service-account-with-iam-role-container
      image: amazon/aws-cli
      command: ["sleep", "3600s"]
```

Note:

1. Value of serviceAccountName must match service account name created in **step 2**

### Step 4 - Validate if we are able to access and get information with aws cli commands

1. access pod with command _**kubectl exec -it service-account-with-iam-role-pod -- bash**_
2. Run any aws cli command to validate access is working fine example - _*aws s3 ls*_
