#!/bin/bash
swapoff	-a

#set required variables
export KUBERNETES_VERSION=v1.35
export CRIO_VERSION=v1.35
export KUBECONFIG=/etc/kubernetes/admin.conf

apt-get	update
apt-get	install	-y software-properties-common curl

#add repositories required for installation
echo "######adding crio and kubernetes repo######"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ / | tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL	https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key | gpg --batch --yes --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ / | tee /etc/apt/sources.list.d/cri-o.list

#contaier runtime installation and configuration
echo "######installing and configuring contaier runtime######"
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

#kubelet kubeadm kubectl installation
echo "######installing kubelet kubeadm kubectl######"
sudo apt-get install -y apt-transport-https	ca-certificates	curl gpg kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

echo "creating kubeadm-config.yaml and performing kubeadm init with kubeadm-config.yaml"
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

hostnamectl set-hostname master

mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown 0:0 /root/.kube/config
ls -l /root/.kube/config


##cilium installation and startup
echo "######cilium installation started here######"
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
cilium install 1.20.1