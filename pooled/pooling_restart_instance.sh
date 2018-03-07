#!/bin/sh
Host=10.177.0.13
D=`date +%Y%m%d%H`
####select IDC id from cloudplayer_center_controller_prod
sql="select  id from interface where physical_node_type=\"IDC\" and is_flag=1;"
/data/service/database/mysql/bin/mysql -h $Host -uywreader -p'hmyw@2016' cloudplayer_center_controller_prod   -e "$sql" 2>/dev/null |tail -n +2 > /tmp/paas_isflag_id
paasid=
for i in `cat /tmp/paas_isflag_id`
do
        i_tmp=${i#*-}
        if [ ! -z $paasid ];then
        paasid=$paasid"|^"$i_tmp"-"
        else
        paasid="^"$i_tmp"-"
        fi
done
#echo $paasid
#select service id from db_service_core
CMD="/data/service/database/mysql/bin/mysql -h10.30.0.189 -uywreader -phmyw@2016 -e "
select_cdcm="select paas_service_id from db_service_core.t_cloud_service_channel where status='inservice' and paas_service_id rlike \"$paasid\";"
$CMD "${select_cdcm}" 2>/dev/null|grep -v paas_service_id >/tmp/${D}_db_service_core_cdcm.info
a=
for i in `cat /tmp/${D}_db_service_core_cdcm.info`
do
        b=${i#*-}
        if [ ! -z $a ];then
        a=$a,$b
        else
        a=$b
        fi
done
#echo $a
if [ -z $a ];then
sql="select c.ip,position,b.ip from service a join instance b  on a.instance_id=b.id join arm_controller c on b.arm_controller_id=c.id where a.app=\"com.tencent.tmgp.sgame\" and a.access_key_id in ('xiamatest01','8F3BB845AD4','D4F92FE4CFC') ;"
else
sql="select c.ip,position,b.ip from service a join instance b  on a.instance_id=b.id join arm_controller c on b.arm_controller_id=c.id where a.app=\"com.tencent.tmgp.sgame\" and a.access_key_id in ('xiamatest01','8F3BB845AD4','D4F92FE4CFC') and a.id not in ($a);"
fi
#echo $sql
/data/service/database/mysql/bin/mysql -h $Host -uywreader -p'hmyw@2016' cloudplayer_controller_prod   -e "$sql" 2>/dev/null |tail -n +2 
info=`/data/service/database/mysql/bin/mysql -h $Host -uywreader -p'hmyw@2016' cloudplayer_controller_prod   -e "$sql" 2>/dev/null |tail -n +2`
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
        echo "`date +"%F %T" ` ${arr[@]}" >> /tmp/restart_ok_${D}.log
        unset arm_position
        echo $arm_position
        fi
done <<EOF
$info
EOF
