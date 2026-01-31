FROM ubuntu:24.04

LABEL contact="gauravbhatkar678"
LABEL java="11"
LABEL maven="3.9"
LABEL helm="4.0"

WORKDIR /opt

ENV M2_HOME=/opt/maven
ENV M2=/opt/maven/bin
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$M2_HOME:$M2:$PATH

ADD https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz .
ADD https://get.helm.sh/helm-v4.0.0-linux-amd64.tar.gz .

RUN tar -zxf apache-maven-3.9.11-bin.tar.gz && mv apache-maven-3.9.11 maven && rm apache-maven-3.9.11-bin.tar.gz\
    && tar -zxf helm-v4.0.0-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm && rm helm-v4.0.0-linux-amd64.tar.gz\
    && apt update && apt install openjdk-11-jre-headless -y\
    && apt autoremove && apt clean