FROM mumblevoip/mumble-server:latest

USER root

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y iproute2 \
    && apt-get install -y net-tools \
    && apt-get install iputils-ping 

RUN rm -f entrypoint.sh

COPY ./configs/route_config.sh entrypoint.sh

USER $NB_UID
