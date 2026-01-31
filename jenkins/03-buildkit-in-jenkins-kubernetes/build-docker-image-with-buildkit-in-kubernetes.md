# Build docker image with buildkit in Jenkins running inside of Kubernetes

### Prerequisits -

1. Running kubeneted cluster
2. Jenkins deployed in kubernetes cluster
3. kubernetes plugin installed in jenkins master

### Step 1 - Configure kubernetes cloud in jenkins

Click on Manage Jenkins > Clouds > New cloud.
Insert details as per below screenshot

![alt text](image-1.png)

Click on create

On New Cloud page ensure Name is same as above
