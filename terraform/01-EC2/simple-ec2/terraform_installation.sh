#!/bin/bash
#user data script from terraform installation
apt-get update && apt-get install -y gnupg software-properties-common python3.12-venv unzip

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

apt update; sudo apt-get install terraform -y

cd ~; git clone https://github.com/maxpain62/practical.git

ln -s /usr/bin/python3 /usr/bin/python

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.9/2025-09-19/bin/linux/amd64/kubectl
chmod +x ./kubectl

cp -p ./kubectl /usr/local/bin/


EksDir=/root/practical/terraform/02-eks

if [ -d $EksDir ];
then
    cd $EksDir && terraform init && terraform apply --auto-approve
fi