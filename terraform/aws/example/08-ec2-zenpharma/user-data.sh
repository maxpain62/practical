#!/bin/bash
#user data script from terraform, aws cli and kubectl installation

echo "##########terraform installation starts here##########"
apt-get update && apt-get install -y gnupg software-properties-common python3.12-venv unzip
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt update; sudo apt-get install terraform -y
echo "##########terraform installation ends here##########"

echo "##########aws cli installation starts here##########"
ln -s /usr/bin/python3 /usr/bin/python
curl -O https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
mv /awscli-bundle.zip /root/awscli-bundle.zip
unzip /root/awscli-bundle.zip -d /root/
sudo /root/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
echo "##########aws cli installation ends here##########"

echo "##########kubectl installation starts here##########"
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.9/2025-09-19/bin/linux/amd64/kubectl
mv /kubectl /root/kubectl
chmod +x /root/kubectl
cp -p /root/kubectl /usr/local/bin/
echo "##########kubectl installation ends here##########"

echo "##########Helm installation starts here##########"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
echo "##########Helm installation end here##########"

echo "##########python installation starts here##########"
sudo apt update
sudo apt install python3 python3-pip python3-venv -y
echo "##########python installation ends here##########"

echo "##########clone github repositories##########"
mkdir -p /root/devops/zenpharma
cd /root/devops/zenpharma
git clone https://github.com/maxpain62/zenpharma-backend.git
git clone https://github.com/maxpain62/zenpharma-frontend.git
git clone https://github.com/maxpain62/zenpharma-gitops.git
git clone https://github.com/maxpain62/zenpharma-documents.git
git clone https://github.com/maxpain62/zenpharma-infra.git
echo "##########cloninng github repositories completed##########"