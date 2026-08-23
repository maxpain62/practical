#!/bin/bash
swapoff	-a

#set required variables
export KUBERNETES_VERSION=v1.35
export CRIO_VERSION=v1.35

apt-get	update
apt-get	install	-y software-properties-common curl

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

#kubelet kubeadm kubectl installation
sudo apt-get install -y apt-transport-https	ca-certificates	curl gpg kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
sudo systemctl start kubelet