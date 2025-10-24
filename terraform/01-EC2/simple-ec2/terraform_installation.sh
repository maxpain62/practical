#!/bin/bash
#user data script from terraform installation
apt-get update && apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

apt update; sudo apt-get install terraform -y

cd ~; git clone https://github.com/maxpain62/practical.git

#EksDir=/root/practical/terraform/eks

#if [ -d $EksDir ];
#then
#    cd $EksDir && terraform init && terraform apply --auto-approve
#fi