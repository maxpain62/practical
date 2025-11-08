#!/bin/bash
#user data script from terraform, aws cli and kubectl installation

#terraform installation starts here
apt-get update && apt-get install -y gnupg software-properties-common python3.12-venv unzip
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt update; sudo apt-get install terraform -y
#terraform installation ends here

#aws cli installation starts here
ln -s /usr/bin/python3 /usr/bin/python
curl -O https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
mv /awscli-bundle.zip /root/awscli-bundle.zip
unzip /root/awscli-bundle.zip -d /root/
sudo /root/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
#aws cli installation ends here

#kubectl installation starts here
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.9/2025-09-19/bin/linux/amd64/kubectl
mv /kubectl /root/kubectl
chmod +x /root/kubectl
cp -p /root/kubectl /usr/local/bin/
#kubectl installation ends here

#cloning practical git repository for eks k8s deployment with help of terraform
cd ~; git clone https://github.com/maxpain62/practical.git
#EksDir=/root/practical/terraform/02-eks
#if [ -d $EksDir ];
#then
#    cd $EksDir && terraform init && terraform apply --auto-approve
#fi
#eks k8s deployment ends here

#cleanup of downloaded files
rm -rf /root/awscli-bundle
rm -rf /root/awscli-bundle.zip
rm -rf /root/kubectl