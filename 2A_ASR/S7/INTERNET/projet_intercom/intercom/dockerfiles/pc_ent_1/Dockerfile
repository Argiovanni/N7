FROM ubuntu:latest

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y isc-dhcp-client \
    && apt-get install -y iputils-ping \
    && apt-get install -y wget \
    && apt-get install -y nmap \
    # nmap pour scanner et "ping" sur un port précis
    && apt-get install -y mumble
    
COPY configs/ /data/