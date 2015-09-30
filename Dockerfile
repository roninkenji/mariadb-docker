FROM roninkenji/slackware-base:latest
MAINTAINER roninkenji

RUN slackpkg -batch=on -default_answer=yes install libaio cxxlibs mariadb perl
COPY myinit /tmp/
RUN chmod +x /tmp/myinit
RUN wget http://mysqltuner.pl/ -O /usr/local/bin/mysqltuner.pl
RUN wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O /usr/local/bin/basic_passwords.txt
RUN chmod +x /usr/local/bin/mysqltuner.pl

ENV MYSQL_ROOT_PASSWORD=password
VOLUME ["/srv/config", "/srv/data" ]
EXPOSE 3306

ENTRYPOINT ["/tmp/myinit"]

