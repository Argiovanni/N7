FROM resystit/bind9:latest

COPY configs/entrypoint /data/
COPY configs/named.conf /etc/bind/
COPY configs/db.ent.uwu /etc/bind/
COPY configs/db-rev.ent.uwu /etc/bind/


RUN chmod a+x data/entrypoint

# COPY configs/db.instar-net.io /etc/bind/zones/

# Expose Ports
# EXPOSE 53/tcp
# EXPOSE 53/udp
# EXPOSE 953/tcp

# CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]
