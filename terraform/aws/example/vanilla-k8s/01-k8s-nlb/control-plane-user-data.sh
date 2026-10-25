#!/bin/bash
swapoff	-a

allControlPlaneCommonTasks() {
    setVariables
    installRequiredPackages
    containerRuntimeInstallation
    kubernetesPackagesInstallation
    checkControlPlaneName
    ciliumInstallation
}

setVariables() {
    echo "-------------"
    echo "Set variables"
    echo "-------------"
    export AWS_REGION=ap-south-1
    export KUBERNETES_VERSION=v1.36
    export CRIO_VERSION=v1.36
    export KUBECONFIG=/etc/kubernetes/admin.conf
}

installRequiredPackages() {
    echo "--------------------------"
    echo "Installe required packages"
    echo "--------------------------"
    apt-get	update
    apt-get	install	-y software-properties-common curl
    echo "------------------------------"
    echo "packages Installtion completed"
    echo "------------------------------"
}

containerRuntimeInstallation() 
{
    echo "------------------------------"
    echo "Container runtime installation"
    echo "------------------------------"

    #add repositories required for installation
    curl -fsSL	https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ / | tee /etc/apt/sources.list.d/kubernetes.list
    curl -fsSL	https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
    echo deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ / | tee /etc/apt/sources.list.d/cri-o.list

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

    echo "----------------------------------------"
    echo "Container runtime installation completed"
    echo "----------------------------------------"
}

kubernetesPackagesInstallation() {
    echo "------------------------------------"
    echo "kubelet kubeadm kubectl installation"
    echo "------------------------------------"
    sudo apt-get install -y apt-transport-https	ca-certificates	curl gpg kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet
    sudo systemctl start kubelet
    echo "----------------------------------------------"
    echo "kubelet kubeadm kubectl installation completed"
    echo "----------------------------------------------"
}

checkControlPlaneName() {
    echo "-----------------------------------------------------------"
    echo "Fetch and check control plane name is controlplane-0 or not"
    echo "-----------------------------------------------------------"
    INSTANCE_TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && \
    INSTANCE_ID=`curl -H "X-aws-ec2-metadata-token: $INSTANCE_TOKEN" http://169.254.169.254/latest/meta-data/instance-id`
    INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region $AWS_REGION --query "Tags[0].Value" --output text)
    if [ "$INSTANCE_NAME" == "controlplane-0"  ]; then
        bootstrapKubernetesControlPlane
        kubeConfigFileCopy
        uploadTokenAndCertificateHash
    else
        sleep 180s
        joinCluster
}

bootstrapKubernetesControlPlane() {
    echo "------------------------"
    echo "bootstrap controlplane-0"
    echo "------------------------"
cat << EOF > kubeadm-config.yaml
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta4
kubernetesVersion: v1.35.0
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
EOF

kubeadm init --config kubeadm-config.yaml
    echo "----------------------------------"
    echo "bootstrap controlplane-0 completed"
    echo "----------------------------------"
}

kubeConfigFileCopy() {
    echo "---------------------"
    echo "Copy kubeconfig files"
    echo "---------------------"
    mkdir -p /root/.kube
    sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
    sudo chown 0:0 /root/.kube/config
    echo "--------------------------"
    echo "Copy kubeconfig files done"
    echo "--------------------------"
}

uploadTokenAndCertificateHash() {
    echo "----------------------------------------"
    echo "upload values to aws ssm parameter store"
    echo "----------------------------------------"
    local CONTROL_PLANE_TOKEN=$(kubeadm token list -o json | jq -r '.token')  
    local CONTROL_PLANE_KUBERNETES_CERTIFICATE_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
    local CONTROL_PLANE_PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $INSTANCE_TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
    aws ssm put-parameter --name "CONTROL_PLANE_TOKEN" --type "String" --value "$CONTROL_PLANE_TOKEN" --overwrite --region $AWS_REGION
    aws ssm put-parameter --name "CONTROL_PLANE_KUBERNETES_CERTIFICATE_HASH" --type "String" --value "$CONTROL_PLANE_KUBERNETES_CERTIFICATE_HASH" --overwrite --region $AWS_REGION
    aws ssm put-parameter --name "CONTROL_PLANE_PRIVATE_IP" --type "String" --value "$CONTROL_PLANE_PRIVATE_IP" --overwrite --region $AWS_REGION
    echo "--------------------------------------------------"
    echo "upload values to aws ssm parameter store completed"
    echo "--------------------------------------------------"
}

joinCluster() {
    echo "-----------------------"
    echo "join kubernetes cluster"
    echo "-----------------------"
    local CONTROL_PLANE_PRIVATE_IP=$(aws ssm get-parameter --name "CONTROL_PLANE_PRIVATE_IP" --region ap-south-1 --query "Parameter.Value" --output text)
    local CONTROL_PLANE_TOKEN=$(aws ssm get-parameter --name "CONTROL_PLANE_TOKEN" --region ap-south-1 --query "Parameter.Value" --output text)
    local CONTROL_PLANE_KUBERNETES_CERTIFICATE_HASH=$(aws ssm get-parameter --name "CONTROL_PLANE_KUBERNETES_CERTIFICATE_HASH" --region ap-south-1 --query "Parameter.Value" --output text)
    kubeadm join $CONTROL_PLANE_PRIVATE_IP:6443 --token $CONTROL_PLANE_TOKEN --discovery-token-ca-cert-hash sha256:$CONTROL_PLANE_KUBERNETES_CERTIFICATE_HASH
}

ciliumInstallation() {
    ##cilium installation and startup
    echo "cilium installation started here"
    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    cilium install 1.20.1
}