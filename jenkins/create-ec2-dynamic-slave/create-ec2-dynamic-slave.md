# Jenkins dynamic EC2 slave

### Why dynamic EC2 slave required?

Jenkins can run / execute CI, CD jobs on jenkins servers itself however, to isolate job execution from orchastration we need to run jobs on remote servers called as Agent.

### Configuring dynamic EC2 slave

#### Step 1 - Install ec2 plugin.

- Click on Manage Jenkins ![](manage-jenkins.png) > Plugins > Available Plugins. Search for EC2 and install plugin
  ![](ec2-dynamic-slave-1.png)
- Below plugins will be automatically installed as dependancy.
  ![](ec2-dynamic-slave-2.png)
- After successful installation Amazon EC2 will appear in New Cloud page. To access this page Click on Managr Jenkins
  ![](manage-jenkins.png) > Clouds > New Cloud. Below page will appear.
  ![alt text](ec2-dynamic-slave-3.png)
- If we can see Amazon EC2 then plugin is successfully installed.

#### Step 2 - Add credentials

- Click on Manage Jenkins ![alt text](manage-jenkins.png) > Credentials > Under Stores scoped to Jenkins Click on System > Global credentials (unrestricted).
- Below page will appear. Click on Add Credentiald
  ![](ec2-dynamic-slave-5.png)
- On New credentials page enter details like below
  ![](ec2-dynamic-slave-6.png)
- Click on add to add private key
  ![](ec2-dynamic-slave-7.png)
- Text box will apprar paste private key in text box
  ![](ec2-dynamic-slave-8.png)
  Note - While copy pasting private key include "-----BEGIN RSA PRIVATE KEY-----" and "-----END RSA PRIVATE KEY-----"
  ![](ec2-dynamic-slave-9.png)
  ![](ec2-dynamic-slave-10.png)
- Click on create button
- Credentials will appear in Global credentials (unrestricted) page
  ![](ec2-dynamic-slave-11.png)

### Step 3 - Create AMI for EC2 slave

- Launch a new instance with same OS as jenkins master.
- While launching new instance you keep other options as default.
- Access newly launched ec2 instance and install jdk version same as you have installed in jenkins instance.
- Create image from instance
  ![](ec2-dynamic-slave-12.png)
- Create Image page will appear. Enter Image name and image description. Keep everything else as default. Click on create image button
  ![](ec2-dynamic-slave-13.png)
  ![](ec2-dynamic-slave-14.png)
- AMI creation will take few minutes.
- Once AMI creation is completed. Newly created AMI will appear in EC2 page under images section. (In below screenshot AMI name is defferent as I am using existing image)
  ![](ec2-dynamic-slave-15.png)

### Step 4 - Create IAM user

- Create IAM user in aws console.
- Create access key for newly created user and note down access key id and secret access key
- we need these details in later steps

### Step 5 - Configure Dynamic EC2 slave

- Click on Manage Jenkins ![alt text](manage-jenkins.png) > Clouds, below page will appear. Click on New Cloud.
  ![](ec2-dynamic-slave-16.png)
- On New Cloud page Enter Cloud name, select Amazon EC2 and click on Create
  ![](ec2-dynamic-slave-17.png)
- Add Amazon EC2 Credentials in New Cloud page
  ![](ec2-dynamic-slave-18.png)
- Add credentials window will appear, Select Kind - AWS Credentials from drop down.
  ![](ec2-dynamic-slave-19.png)
- Enter Access Key ID and Secret Access Key we generated in Step 4
  ![](ec2-dynamic-slave-20.png)
- On New Cloud page under Amazon EC2 Credentials select newly created credentials
  ![](ec2-dynamic-slave-21.png)
- Scroll down and select EC2 Key Pair's Private Key from drop down and click on Test Connection
  ![](ec2-dynamic-slave-22.png)
- After clicking on Test Connection success will appear on page.
- Click on Advanced and enter Instance Cap.
  This setting will add capping to number of EC2 instances Jenkins Master can create at a time.
  In this scenario I have capped number to 2.
  This means Jenkins Master can spin only 2 instances at a time.
  ![](ec2-dynamic-slave-23.png)
- Scroll down and add AMI details like Description and AMI id we created in Spet 3.
- Click on check AMI and you will get source details of AMI
  ![](ec2-dynamic-slave-24.png)
- Now select preffered instance type. I am selecting t3.medium
- Enter Security groups name, Remote FS root.
  ![](ec2-dynamic-slave-25.png)
- Enter Remote user and AMI type
  ![](ec2-dynamic-slave-26.png)
- Scroll down and enter Labels, Usage and Idle termination time
  ![](ec2-dynamic-slave-27.png)
- Scroll down and click on Advanced, Enter number of executers, Subnet IDs for VPC
  ![](ec2-dynamic-slave-28.png)
- Scroll down and locate Host Key Verification Strategy.
  select accept new and click on save.
- Don't change other options.

### Step 6 - Validate pipeline Job is running

- Click on new item
  ![](ec2-dynamic-slave-29.png)
- Enter item name and select pipeline
  ![](ec2-dynamic-slave-30.png)
- Click on pipeline button on left side of page. Enter declarative pipeline code
```
pipeline {
    agent {label 'ec2-slave-cloud'}
    stages {
        stage ('echo') {
            steps {
                echo 'Hello'
            }
        }
    }
}
```