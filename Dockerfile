FROM roninkenji/slackware-base:latest
MAINTAINER roninkenji

RUN slackpkg -batch=on -default_answer=yes install libaio cxxlibs mariadb perl
COPY myinit /usr/local/bin/
RUN chmod +x /usr/local/bin/myinit
RUN wget -nv https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl -O /usr/local/bin/mysqltuner.pl
RUN wget -nv https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O /usr/local/bin/basic_passwords.txt
RUN chmod +x /usr/local/bin/mysqltuner.pl

ENV MYSQL_ROOT_PASSWORD=password
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/myinit"]

