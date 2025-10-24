FROM alpine:3.21.0
RUN apk update && apk add curl\
    && curl -LO https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl && chmod 777 kubectl && mv kubectl /usr/bin/kubectl\
    && adduser -D -h /home/appuser -s /bin/sh appuser
USER appuser