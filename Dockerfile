FROM roninkenji/slackware-base:latest
MAINTAINER roninkenji

RUN slackpkg -batch=on -default_answer=yes install libaio cxxlibs mariadb && rm -rv /usr/doc
COPY rc.mysqld /etc/rc.d/
RUN chmod +x /etc/rc.d/rc.mysqld
RUN echo "!includedir /etc/my.cnf.custom" >> /etc/my.cnf && mkdir -p /etc/my.cnf.custom

VOLUME ["/etc/my.d.custom", "/var/lib/mysql" ]
EXPOSE 3306

ENTRYPOINT ["/etc/rc.d/rc.mysqld", "start"]

