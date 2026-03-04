#!/bin/bash
#user data script from terraform installation

#terraform installation starts here
apt-get update && apt-get install -y gnupg software-properties-common python3.12-venv unzip
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt update; sudo apt-get install terraform -y
#terraform installation ends here


#azure cli installation starts here
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y

sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

AZ_DIST=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources

sudo apt-get update
sudo apt-get install azure-cli -y

#azure cli installation ends here

#login to azure using managed identity
az login --identity
#install kubectl using azure cli
az aks install-cli

#clone the practical repository
git clone https://github.com/maxpain62/practical.git