FROM ubuntu:24.04

LABEL os="ubuntu:24.04"
LABEL java1="21"
LABEL java2="11"
LABEL maven="3.9"
LABEL contact="gauravbhatkar"

#Set environment variable
ENV m2_home=/opt/maven
ENV m2=/opt/maven/bin
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$m2_home:$m2:$JAVA_HOME/bin:$PATH

#download maven 
ADD https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz /

#update and install jdk11, jdk21, openssh-server
RUN apt update && apt install openjdk-21-jre-headless openjdk-11-jre-headless openssh-server ca-certificates curl -y \
    #untar maven and move to opt
    && tar -zxf apache-maven-3.9.11-bin.tar.gz && mv apache-maven-3.9.11 /opt/maven \
    && rm apache-maven-3.9.11-bin.tar.gz && apt autoremove && apt clean \
    #adding jenkins user and change password
    && adduser --quiet jenkins && echo "jenkins:jenkins" | chpasswd \
    && mkdir /home/jenkins/.ssh/ /home/jenkins/.m2/

#Copy required files

COPY id_ed25519.pub /home/jenkins/.ssh/authorized_keys 
COPY toolschains.xml /home/jenkins/.m2/toolschains.xml

#change permission for jenkins home
RUN chown -R jenkins:jenkins /home/jenkins/.ssh/ && chmod 600 /home/jenkins/.ssh/authorized_keys \
    && chmod 700 /home/jenkins/.ssh/

EXPOSE 22

#Start ssh server
CMD ["/usr/sbin/sshd", "-D"]