#!/bin/bash
swapoff	-a
setVariables
installRequiredPackages
containerRuntimeInstallation
kubernetesPackagesInstallation
checkControlPlaneName

setVariables() {
    echo "-------------"
    echo "Set variables"
    echo "-------------"
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
}

kubernetesPackagesInstallation() {
#kubelet kubeadm kubectl installation
    sudo apt-get install -y apt-transport-https	ca-certificates	curl gpg kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet
    sudo systemctl start kubelet
}

checkControlPlaneName() {
    INSTANCE_TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && \
    INSTANCE_ID=`curl -H "X-aws-ec2-metadata-token: $INSTANCE_TOKEN" http://169.254.169.254/latest/meta-data/instance-id`
    INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --region ap-south-1 --query "Tags[0].Value" --output text)
    if [ "$INSTANCE_NAME" == "controlplane-0"  ]; then
        bootstrapKubernetesControlPlane
    else
        sleep 180s
        kubeadm join --discovery-token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:1234..cdef --control-plane 1.2.3.4:6443
        kubeConfigFileCopy
}

bootstrapKubernetesControlPlane() {
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
kubeConfigFileCopy
}

kubeConfigFileCopy() {
    mkdir -p /root/.kube
    sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
    sudo chown 0:0 /root/.kube/config
    ciliumInstallation
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