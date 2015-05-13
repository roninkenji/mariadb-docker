FROM roninkenji/slackware-base:latest
MAINTAINER roninkenji

RUN slackpkg -batch=on -default_answer=yes install libaio cxxlibs mariadb
COPY myinit /tmp/
RUN chmod +x /tmp/myinit

ENV MYSQL_ROOT_PASSWORD=password
VOLUME ["/srv/config", "/srv/data" ]
EXPOSE 3306

ENTRYPOINT ["/tmp/myinit"]

