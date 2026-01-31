FROM ubuntu:24.04

LABEL os="ubunru2-4.04"
LABEL maven="3.9.11"
LABEL java="jre-11"

#Default present dir
WORKDIR /opt/

#Set environment variables
ENV M2_HOME=/opt/maven
ENV M2=/opt/maven/bin
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$M2_HOME:$M2:$PATH

#Download maven
ADD https://archive.apache.org/dist/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz .

#Untar downloaded files and do cleanup
RUN tar -zxf apache-maven-3.9.11-bin.tar.gz && mv apache-maven-3.9.11 maven && rm apache-maven-3.9.11-bin.tar.gz\
    && apt update && apt install openjdk-11-jre-headless -y\
    && apt autoremove && apt clean