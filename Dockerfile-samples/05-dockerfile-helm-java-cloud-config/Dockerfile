FROM amazon/aws-cli

LABEL os="amazonlinux-2023"
LABEL helm="v3.20.0"
LABEL contact="maxpain62@gmail.com"
LABEL maven="3.9"
LABEL java="11-amazon-corretto-headless"

ENV M2_HOME=/opt/maven
ENV M2=/opt/maven/bin
ENV PATH=$M2_HOME:$M2:$PATH

ADD https://get.helm.sh/helm-v3.20.0-linux-amd64.tar.gz /tmp/helm-v3.20.0-linux-amd64.tar.gz
ADD https://archive.apache.org/dist/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz /tmp/apache-maven-3.9.11-bin.tar.gz

RUN yum install tar gzip java-11-amazon-corretto-headless git -y && \
    tar -zxf /tmp/helm-v3.20.0-linux-amd64.tar.gz -C /tmp/ && mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    tar -zxf /tmp/apache-maven-3.9.11-bin.tar.gz -C /tmp/ && mv /tmp/apache-maven-3.9.11 /opt/maven && \
    git clone https://github.com/maxpain62/eos-cloud-config-repo.git /etc/eos-cloud-config-repo/ &&\
    yum remove tar gzip git -y && yum clean all && rm -rf /tmp/*