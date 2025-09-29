FROM ubuntu:24.04
WORKDIR /root/
ADD https://s3.amazonaws.com/aws-cli/awscli-bundle.zip .
RUN apt update && apt install unzip python3.12-venv -y && apt autoremove && unzip awscli-bundle.zip &&\
    /usr/bin/python3.12 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && rm -rf awscli-bundle*