FROM ubuntu:24.04

#Default present dir
WORKDIR /opt/

#Set environment variables
ENV M2_HOME=/opt/maven
ENV M2=/opt/maven/bin
ENV JAVA_HOME=/opt/jdk-12.0.2
ENV PATH=$JAVA_HOME/bin:$M2_HOME:$M2:$PATH

#Download jdk and maven
ADD https://download.java.net/java/GA/jdk12.0.2/e482c34c86bd4bf8b56c0b35558996b9/10/GPL/openjdk-12.0.2_linux-x64_bin.tar.gz .
ADD https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz .

#Untar downloaded files and do cleanup
RUN tar -zxf apache-maven-3.9.11-bin.tar.gz && tar -zxf openjdk-12.0.2_linux-x64_bin.tar.gz && \
    mv apache-maven-3.9.11 maven && rm apache-maven-3.9.11-bin.tar.gz && rm openjdk-12.0.2_linux-x64_bin.tar.gz &&\
    apt autoremove && apt clean