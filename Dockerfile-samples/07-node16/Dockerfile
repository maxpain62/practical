FROM ubuntu:24.04

WORKDIR /opt

ENV PATH=/opt/node-v16.20.2-linux-x64/bin:$PATH

ADD https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-x64.tar.xz /opt/

RUN apt update && apt install tar xz-utils -y && \
    mkdir /opt/dist && mkdir /opt/node_modules && tar -xf node-v16.20.2-linux-x64.tar.xz