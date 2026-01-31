FROM ubuntu:24.04

LABEL os="ubuntu-24.04"
LABEL helm="3.20.0"
LABEL contact="maxpain62@gmail.com"

RUN apt update && apt-get install curl gpg apt-transport-https -y &&\
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null &&\
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list &&\
    apt update && apt install helm -y && apt clean && apt autoremove