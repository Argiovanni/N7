FROM ubuntu:latest

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y isc-dhcp-client \
    && apt-get install -y iputils-ping \
    && apt-get install -y wget 

COPY configs/ /data/