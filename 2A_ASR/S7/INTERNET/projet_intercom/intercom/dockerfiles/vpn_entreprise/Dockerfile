FROM ubuntu:latest

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y wget \
    && apt-get install -y vim \
    && apt-get install -y openvpn \
    && apt-get install -y iptables \
    && apt-get install -y openssl  \
    && apt-get install -y ca-certificates  gnupg\
    && apt-get install -y curl  \
    && apt-get install -y unbound \
    && apt-get install -y git \
    && apt-get install -y iputils-ping\
    && apt-get install -y iproute2 \
    && apt-get install -y easy-rsa \
    && apt-get install -y systemd \
    && apt-get install -y zsh \
    && sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

COPY configs/entrypoint /data/
COPY configs/openvpn/. /etc/openvpn