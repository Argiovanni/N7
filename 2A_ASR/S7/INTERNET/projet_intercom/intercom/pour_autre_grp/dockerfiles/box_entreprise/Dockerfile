FROM ubuntu:latest

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install isc-dhcp-server -y \
    && apt-get install -y isc-dhcp-client \
    && apt-get install -y iptables

COPY configs/ /data/