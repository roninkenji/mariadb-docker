#!/bin/bash
DATADIR=/srv/data
CONFDIR=/srv/config
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-password}
#install config files
if [ ! -f ${CONFDIR}/my.cnf ]; then
  cat > ${CONFDIR}/my.cnf <<EOF
[server]
basedir=/usr
datadir=${DATADIR}
plugin-dir=/usr/lib64/mysql/plugin
user=mysql

!includedir ${CONFDIR}/my.cnf.d
EOF
fi
if [ ! -d ${CONFDIR}/my.cnf.d ]; then
  mkdir -p ${CONFDIR}/my.cnf.d
  cat > ${CONFDIR}/my.cnf.d/innodb.cnf << EOF
[mysqld]
innodb-file-per-table=1
EOF
fi
# Install tables
if [ ! -d ${DATADIR}/mysql ]; then
  #invoke init routines
  echo "First run... setting up..."
  mysql_install_db --defaults-extra-file=${CONFDIR}/my.cnf
  chown mysql:mysql -Rv ${DATADIR}

  #initial user lockdown
  cat > /tmp/init.sql << EOF
DELETE FROM user WHERE USER LIKE "" OR HOST LIKE "${HOSTNAME}"
CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION
GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION
FLUSH PRIVILEGES
EOF
elif [ -n "${MYSQL_SET_ROOT_PASSWORD}" ]; then
  echo "Asked to reset root password..."
  cat > /tmp/init.sql << EOF
UPDATE mysql.user SET PASSWORD=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE USER='root' AND HOST='%'
FLUSH PRIVILEGES
EOF
fi

[ -f /tmp/init.sql ] && INITFILE='--init-file=/tmp/init.sql'
# Start mysqld:
# If there is an old PID file (no mysqld running), clean it up:
if [ -r /var/run/mysql/mysql.pid ]; then
  if ! ps axc | grep mysqld 1> /dev/null 2> /dev/null ; then
    echo "Cleaning up old /var/run/mysql/mysql.pid."
    rm -f /var/run/mysql/mysql.pid
  fi
fi
exec mysqld_safe --defaults-extra-file=${CONFDIR}/my.cnf --pid-file=/var/run/mysql/mysql.pid ${INITFILE}
