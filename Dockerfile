FROM arm32v6/alpine:latest

LABEL MAINTAINER="Greg White grewhit25@gmail.com"

RUN apk add -U -v \
    nfs-utils \
	bash

ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.2.1/s6-overlay-armhf.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-armhf.tar.gz -C / && \
    mkdir /app 

COPY s6/config.init /etc/cont-init.d/00-config
COPY s6/rpcbind.run /etc/services.d/rpcbind/run
COPY s6/mountd.run /etc/services.d/mountd/run
COPY app/ /app

EXPOSE 111/udp 2049/tcp 2049/udp

ENTRYPOINT ["/app/start.sh", "/init"]
