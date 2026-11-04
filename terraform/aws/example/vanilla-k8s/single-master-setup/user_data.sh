#!/bin/bash
swapoff	-a
hostnamectl set-hostname controlplane

setVariable()
{
    echo "----------------------"
    echo "set required variables"
    echo "----------------------"
    export KUBERNETES_VERSION=v1.35
    export CRIO_VERSION=v1.35
    export KUBECONFIG=/etc/kubernetes/admin.conf
    export AWS_REGION=ap-south-1
    echo "----------------------"
    echo "required variables set"
    echo "----------------------"
}

installRequiredPackages()
{
    echo "-------------------------"
    echo "Install required packages"
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
}

containerRuntimeInstallation() {

    echo "----------------------------------------------------------------"
    echo "adding crio and kubernetes repo and installing container runtime"
    echo "----------------------------------------------------------------"
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ / | tee /etc/apt/sources.list.d/kubernetes.list
    curl -fsSL	https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
    echo deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ / | tee /etc/apt/sources.list.d/cri-o.list
    
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
    echo "--------------------------------------------------------------"
    echo "added crio and kubernetes repo and installed container runtime"
    echo "--------------------------------------------------------------"
}

kubernetesPackagesInstallation() {
    echo "------------------------------------------------------------------------------------"
    echo "installing kubelet kubeadm kubectl and initializing kubeadm with kubeadm-config.yaml"
    echo "------------------------------------------------------------------------------------"
    sudo apt-get install -y apt-transport-https	ca-certificates	curl gpg kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet

    #creating kubeadm-config.yaml and performing kubeadm init with kubeadm-config.yaml
cat << EOF > kubeadm-config.yaml
# kubeadm-config.yaml    
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.35.0
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF
    kubeadm init --config kubeadm-config.yaml
    echo "-----------------------------------------------------------------"
    echo "kubelet kubeadm kubectl installation and initialization completed"
    echo "------------------------------- ----------------------------------"
}

clusterJoinCommandGeneration() {
    echo "-------------------------------"
    echo "generating cluster join command"
    echo "-------------------------------"
    #Generate custer joining command for worker nodes
    CLUSTER_JOINING_COMMAND_WORKER_NODE=$(kubeadm token create --print-join-command)
    #Upload custer joining command for worker nodes to ssm parameter store
    aws ssm put-parameter --name "CLUSTER_JOINING_COMMAND_WORKER_NODE" --type "String" --value "$CLUSTER_JOINING_COMMAND_WORKER_NODE" --overwrite --region $AWS_REGION   
    echo "-------------------------------"
    echo "cluster join command generated"
    echo "-------------------------------"
}

fileCopyAndHostnameSetup() {
    echo "--------------------------------------------"
    echo "copying kubeconfig file and setting hostname"
    echo "--------------------------------------------"
    mkdir -p /root/.kube
    sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
    sudo chown 0:0 /root/.kube/config
    ls -l /root/.kube/config
    echo "---------------------------------------"
    echo "kubeconfig file copied and hostname set"
    echo "---------------------------------------"
}


ciliumInstallation() {
    echo "---------------------------"
    echo "cilium installation started"
    echo "---------------------------"
    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    cilium install 1.20.1
    echo "-----------------------------"
    echo "cilium installation completed"
    echo "-----------------------------"
}

setVariable
installRequiredPackages
awsCliInstallation
containerRuntimeInstallation
kubernetesPackagesInstallation
clusterJoinCommandGeneration
fileCopyAndHostnameSetup
ciliumInstallation