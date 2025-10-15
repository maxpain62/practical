# Deploying mysql with CRD (Custom Resource Definition)

### Step 1 - Installing MySQL Operator for Kubernetes

- Run following commands

```
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm repo update
helm install my-mysql-operator mysql-operator/mysql-operator  --namespace mysql-operator --create-namespace
```

Below is expected output :

```
kubectl get all --namespace mysql-operator
NAME                                 READY   STATUS    RESTARTS   AGE
pod/mysql-operator-9bf5fd568-lzfq9   1/1     Running   0          15m

NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/mysql-operator   ClusterIP   10.100.85.218   <none>        9443/TCP   15m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mysql-operator   1/1     1            1           15m

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/mysql-operator-9bf5fd568   1         1         1       15m
```

### Step 2 - Installing MySQL InnoDB Cluster

- Create storage class with below yaml code

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: mysql-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
```

- Create inputs.yaml file with following code.
  - you can change values in input.yaml file as per your requirements

```
credentials:
  root:
    user: root
    password: sakila
    host: "%"
datadirVolumeClaimTemplate:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

- Run below commands

```
helm install mycluster mysql-operator/mysql-innodbcluster  --set tls.useSelfSigned=true --values inputs.yaml

```

### Step 3 - Validation

- Validate Installation is successful with _**kubectl get all**_ if installation is successful you will get result similler to this:-

```
NAME              READY   STATUS    RESTARTS   AGE
pod/mycluster-0   1/2     Running   0          19s
pod/mycluster-1   1/2     Running   0          19s
pod/mycluster-2   1/2     Running   0          19s

NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
                 AGE
service/mycluster             ClusterIP   10.100.86.149   <none>        3306/TCP,33060/TCP,6446/TCP,6448/TCP,6447/TCP,6449/TCP,6450/TCP,8443/TCP   19s
service/mycluster-instances   ClusterIP   None            <none>        3306/TCP,33060/TCP,33061/TCP
                 19s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mycluster-router   0/0     0            0           19s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/mycluster-router-64bdd984bb   0         0         0       20s

NAME                         READY   AGE
statefulset.apps/mycluster   0/3     20s

```

Reference - https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-introduction.html
