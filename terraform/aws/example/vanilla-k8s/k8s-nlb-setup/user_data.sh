#!/bin/bash
swapoff	-a

#set required variables
export KUBERNETES_VERSION=v1.36
export CRIO_VERSION=v1.36
export KUBECONFIG=/etc/kubernetes/admin.conf

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

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


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