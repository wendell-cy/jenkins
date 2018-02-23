#!/bin/bash
count=`hostname|awk -F"-" '{print NF}'`
if [ $count == 3 ];then
        minfo=`hostname|awk -F"-" '{print $3}'`
        type=`hostname|awk -F"-" '{print $3}'`
        IP=`hostname|awk -F"-" '{print $2}'`
else
        minfo=`hostname`
fi
echo "install mysql ................................"
cd /data/src
id mysql
if [ $? -eq 1 ];then
        groupadd -g 502 mysql
        useradd -u 502 -g 502 mysql
fi

install_path=/data/service/database/mysql
curr_path=`pwd`

#if [ -f $install_path/mysql.pid ];then
#       old_pid=`cat $install_path/mysql.pid`
#       if [ ! -z $old_pid ];then
#               old_pids=(`ps -ef |awk -v a=$old_pid '{if($2==a)print $3,$2}'`)
#               if [ ! -z  $old_pids ];then
#                       kill -i ${old_pids[@]}
#               fi
#       fi
#fi
old_pid=(`ps -ef |grep mysqld|grep -v grep |awk '{print $2}'`)
if [ ${#old_pid[@]} -ge 1 ];then
        kill -9 ${old_pid[@]}
fi
rm -rf $install_path/*
[ -d /data/log/mysql ] || mkdir -p /data/log/mysql
chown mysql:mysql /data/log/mysql
/bin/cp $curr_path/mysql/epel.repo /etc/yum.repos.d/
/bin/cp $curr_path/mysql/RPM-GPG-KEY-EPEL-6 /etc/pki/rpm-gpg/
[ -d $install_path ] || mkdir -p $install_path
tar zxf /data/src/mysql-5.6.32.tar.gz -C /tmp
cd /tmp/mysql-5.6.32/
#yum install -y https://www.percona.com/redir/downloads/percona-release/redhat/latest/percona-release-0.1-4.noarch.rpm
yum install -y ncurses-devel ncurses cmake perl-IO-Socket-SSL perl-TermReadKey perl-Term-ReadKey perl-Time-HiRes perl-DBD-MySQL perl-DBI  gcc gcc-c++ bison expect
#yum install -y ncurses-devel ncurses cmake perl-IO-Socket-SSL perl-TermReadKey perl-Term-ReadKey perl-Time-HiRes perl-DBD-MySQL perl-DBI percona-toolkit percona-xtrabackup gcc
gcc-c++ bison expect
if [ $? -eq 1 ];then
        exit
fi
/usr/bin/cmake -DCMAKE_INSTALL_PREFIX=$install_path -DMYSQL_UNIX_ADDR=$install_path/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_INNOBASE_STORAGE
_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_DATADIR=$install_path/data -DMYSQL_USER=mysql
make -j`grep -c ^processor /proc/cpuinfo` && make install
cp $curr_path/mysql/my.cnf $install_path
cp $curr_path/mysql/start.sh $install_path
cd $install_path
if [ $minfo == "PAAS02" ];then
        sed -i "s/\(server-id\).*/\1 = 22/g" $install_path/my.cnf
fi
./scripts/mysql_install_db --defaults-file=my.cnf
chown mysql:mysql $install_path -R
rm -f /etc/my.cnf
sh start.sh
sleep 10
rm -rf /tmp/mysql-5.6.32/
grep "/data/service/database/mysql/bin" /etc/profile >/dev/null
if [ $? -ne 0 ];then
echo "export PATH=/data/service/database/mysql/bin/:\$PATH" >> /etc/profile
fi
grep /data/service/database/mysql /etc/rc.local >/dev/null
if [ $? -ne 0 ];then
echo "cd /data/service/database/mysql && sh start.sh" >> /etc/rc.local
fi
cd $curr_path/mysql
./init_mysql.expect $install_path
if [ $? -ne 0 ];then
        echo "mysql install failed"
        exit 1
fi
cp -f /data/src/mysql/zabbix.cnf /etc/my.cnf
slavestatus=1
if [ $type == "PAAS01" ];then
        sed -i "s/10.100.0.2/10.${IP}.0.3/g" /data/src/mysql/grant.sql
        /data/service/database/mysql/bin/mysql -u root -phaima123outfox < /data/src/mysql/grant.sql
        while [ $slavestatus != 0 ]
        do
                /data/service/database/mysql/bin/mysql -udba -phaima123outfox -h 10.${IP}.0.3 -e "status" > /dev/null 2>/dev/null
                if [ $? = 0 ];then
                        /data/service/database/mysql/bin/mysql -uroot -phaima123outfox  < /data/src/mysql/idc.sql
                        slavestatus=0
                fi
                sleep 10
        done
elif [ $type == "PAAS02" ];then
        sed -i "s/10.100.0.2/10.${IP}.0.2/g" /data/src/mysql/grant.sql
        /data/service/database/mysql/bin/mysql -u root -phaima123outfox < /data/src/mysql/grant.sql
fi

> /data/log/mysql/mysql_error.log
chown mysql.mysql /data/log/mysql/mysql_error.log
chmod +r  /data/log/mysql/mysql_error.log