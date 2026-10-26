#!/bin/bash
swapoff	-a

setVariables() {
    echo "-------------"
    echo "Set variables"
    echo "-------------"
    #set required variables
    export KUBERNETES_VERSION=v1.36
    export CRIO_VERSION=v1.36
    export AWS_REGION=ap-south-1
}

installRequiredPackages() {
    echo "-------------------------"
    echo "Install requires packages"
    echo "-------------------------"
    apt-get	update
    apt-get	install	-y software-properties-common curl gnupg python3.12-venv unzip
    echo "---------------------------"
    echo "required packages installed"
    echo "---------------------------"
}

awsCliInstallation() {
    echo "----------------------------"
    echo "aws cli installation started"
    echo "----------------------------"
    ln -s /usr/bin/python3 /usr/bin/python
    curl -O https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    mv /awscli-bundle.zip /root/awscli-bundle.zip
    unzip /root/awscli-bundle.zip -d /root/
    sudo /root/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    echo "------------------------------"
    echo "aws cli installation completed"
    echo "------------------------------"
    sleep 5s
}

addRepositories() {
    echo "------------------------------------"
    echo "Add kubernetes and CRIO repositories"
    echo "------------------------------------"
    #add repositories required for installation
    curl -fsSL	https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ / | tee /etc/apt/sources.list.d/kubernetes.list
    curl -fsSL	https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
    echo deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ / | tee /etc/apt/sources.list.d/cri-o.list
    echo "---------------------------------------------------"
    echo "kubernetes and CRIO repositories added successfully"
    echo "---------------------------------------------------"
}

installContainerRuntime() {
    echo "------------------------------"
    echo "Install container runtime CRIO"
    echo "------------------------------"
    #contaier runtime installation and configuration
    apt-get	update 
    apt-get	install -y cri-o
    mv /etc/cni/net.d/10-crio-bridge.conflist.disabled	/etc/cni/net.d/10-crio-bridge.conflist
    systemctl start crio.service
    modprobe br_netfilter
    sysctl -w net.ipv4.ip_forward=1

    cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
    net.ipv4.ip_forward = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
EOF
    echo "--------------------------------"
    echo "container runtime CRIO installed"
    echo "--------------------------------"
}

kubernetesPackagesInstallation() {
    echo "------------------------------------"
    echo "kubelet kubeadm kubectl installation"
    echo "------------------------------------"
    #kubelet kubeadm kubectl installation
    sudo apt-get install -y apt-transport-https	ca-certificates	curl gpg kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet
    sudo systemctl start kubelet
    echo "------------------------------------------------"
    echo "kubelet kubeadm kubectl installated successfully"
    echo "------------------------------------------------"
}

fetchJoiningCommandAndJoin() {
    echo "-------------------------------------------------------------"
    echo "Fetch cluster joining command and join cluster as worker node"
    echo "-------------------------------------------------------------"
    sleep 210s
    CLUSTER_JOINING_COMMAND_WORKER_NODE=$(aws ssm get-parameter --name "CLUSTER_JOINING_COMMAND_WORKER_NODE" --region $AWS_REGION --query "Parameter.Value" --output text)
    $CLUSTER_JOINING_COMMAND_WORKER_NODE
    echo "-----------------------------"
    echo "Joined cluster as worker node"
    echo "-----------------------------"
}

setVariables
installRequiredPackages
installRequiredPackages
addRepositories
installContainerRuntime
kubernetesPackagesInstallation
fetchJoiningCommandAndJoin