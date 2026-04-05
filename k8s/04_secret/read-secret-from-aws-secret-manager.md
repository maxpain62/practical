# Read secrets from aws secrets manager

## Prerequisits
1. running EKS cluster
2. eksctl installed in machine (from where you are accessing eks cluster)
3. Confirm _**OpenID Connect provider URL**_ is visible in overview page of EKS cluster

### Step 1 - Install "AWS Secrets Store CSI Driver provider (ASCP)" in EKS cluster
 1. execute command to install ASCP 
    - **eksctl create addon --cluster <your_cluster> --name aws-secrets-store-csi-driver-provider**
 2. verify installation 
    - **kubectl get pod -A | grep secret**
    - **kubectl get pod -n aws-secrets-manager**


### Step 2 - Create IAM role as below
1. Select _**Web identity**_ from _**Trusted entity type**_
2. From _**Web identity**_ drop down select OIDC provider which is associated with current eks cluster
3. Select _**sts.amazonaws.com**_ from audiance dropdown
4. click on add condition button
   - In key dropdown select OIDC provider
   - Condition - StringEquals
   - Value - _**system:serviceaccount:default:ServiceAccountName**_
   - Replace _**default**_ with desired namespace name in which you are creating the pod/deployment
   - Replace **ServiceAccountName** with name of service account you will create inside eks cluster with yaml file
5. Select policy you want to attach to your role. click next
6. Provide role name and click on create role. 


### Step 3 - Associate IAM role with service account
Use below sample yaml code
- replace value of **eks.amazonaws.com/role-arn** with role arn which was created in step 2

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: service-account-with-iam-role
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::AccountID:role/ServiceAccountRoleName"
```

### Step 4 - Create SecretProviderClass
Use below sample yaml code
 - Replace **objectName** with secret name
```
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: nginx-irsa-deployment-aws-secrets
spec:
  provider: aws
  parameters:
    objects: |
        - objectName: "demo/secret"
          objectType: "secretsmanager"
```

### Step 5 - Create pod and mount secret
Use below sample yaml code
```
apiVersion: v1
kind: Pod
metadata:
  name: irsa-pod
spec:
  serviceAccountName: service-account-with-iam-role
  volumes:
    - name: secrets-store-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "nginx-irsa-deployment-aws-secrets"
  containers:
    - name: irsacontainer
      image: amazon/aws-cli
      command:
        - sleep
        - "3600"
      volumeMounts:
        - name: secrets-store-inline
          mountPath: /mnt/secrets-store
          readOnly: true
```

### Verify if pod able to access / read secrets from aws secrets manager
1. Access pod and check volume **/mnt/secrets-store** is mounted or not
2. file with secret name will exist in this path, cat the file and vefiry secret values.