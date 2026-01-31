FROM amazon/aws-cli

LABEL os="amazonlinux-2023"
LABEL helm="v3.20.0"
LABEL contact="maxpain62@gmail.com"

WORKDIR /tmp/

ADD https://get.helm.sh/helm-v3.20.0-linux-amd64.tar.gz /tmp/helm-v3.20.0-linux-amd64.tar.gz

RUN yum install tar gzip -y && tar -zxvf /tmp/helm-v3.20.0-linux-amd64.tar.gz && mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    yum remove tar gzip -y && yum clean all && rm -rf /tmp/*