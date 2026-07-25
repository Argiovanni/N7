FROM nginx:latest

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y iproute2 \
    && apt-get install -y net-tools \
    && apt-get install -y iptables

COPY ./pages/index.html /usr/share/nginx/html/index.html
COPY ./configs/ /data/
