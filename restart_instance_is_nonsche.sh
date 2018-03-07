#!/bin/sh
Host=`facter ipaddress_bond1`
Host=`echo $Host|sed "s/.0.1$/.0.3/g"`
sql="select c.ip,position from instance_status a join instance b  on a.instance_id=b.id join arm_controller c on b.arm_controller_id=c.id where a.status='NONSCHEDULABLE'; "
#sql="select c.ip,position from instance_status a join instance b  on a.instance_id=b.id join arm_controller c on b.arm_controller_id=c.id where a.instance_id in (select instance_id from service  where create_timestamp like \"%2017-08-30%\") "
info=`/data/service/database/mysql/bin/mysql -h $Host -uywreader -p'hmyw@2016' cloudplayer_controller_idcprod   -e "$sql" 2>/dev/null |tail -n +2`
while read line
do
        if [ ! -z "${line}" ];then
        arr=($line)
        arm_ip=${arr[0]}
        arm_position=${arr[1]}
        export arm_position
        echo "=============================================="
        echo "`date +"%F %T"` [INFO] armController =>$arm_ip $arm_position<= is rebooting..."
        (
        sleep 1
        echo "shell"
        sleep 1
        echo "shutcpu $arm_position"
        #echo "ipmc -6"
        sleep 1
        echo "powercpu $arm_position"
        sleep 1
         )|telnet $arm_ip

        sleep 3
        unset arm_position
        echo $arm_position
        fi
done <<EOF
$info
EOF
