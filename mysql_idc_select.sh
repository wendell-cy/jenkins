#!/bin/bash
count=$#
if [ $1 == "prod" ];then
        dbname=cloudplayer_controller_idcprod
elif [ $1 == "pre" ];then
        dbname=cloudplayer_controller_idcpre
else
        echo "Usage:$0 pre|prod"
fi

if [ $2 == "app_info"  -a ! -z "$3" ];then
        packageName=$3
elif [ $2 == "play_app"  -a ! -z "$3" ];then
      packageName=$3
elif [ $2 == "app_info" -a $2 == "play_app" ];then
       echo "usage:$0 app_info packageName"
       exit 0
else
       :
fi
case $2 in
        ota_version)
           /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox' ${dbname}  -e "select substring(version_info,139,15),count(*) from instance group by substring(version_info,139,15);"  2>/dev/null
        #/data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'   -e "SELECT count(*) FROM cloudplayer_controller_idcprod.instance where version_info like '%0.21.20170531%' ;"  2>/dev/null
        # /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'   -e "SELECT count(*) FROM cloudplayer_controller_idcprod.instance  ;"  2>/dev/null
        ;;
        instance_status)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox' ${dbname}  -e "SELECT status,count(*) FROM instance_status group by status ;"  2>/dev/null
        ;;
        service_info)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'  ${dbname}  -e "select a.instance_id,status,app from service a join instance_status b on a.instance_id=b.instance_id;"  2>/dev/null
        ;;
        app_info)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'  ${dbname}  -e "select count(id) from instance_app a left join instance b on a.instance_id=b.id where app=\"$packageName\";"  2>/dev/null
        ;;
        play_app)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'  ${dbname}  -e "select id,app,user_info from service  where app=\"$packageName\";"  2>/dev/null
        ;;
        armcontroller_info)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'   ${dbname}  -e "select ip from arm_controller;"  2>/dev/null|grep -v ip
        ;;
        nat_map)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'   ${dbname}  -e "select count(*) from nat_cdn_mapping;"  2>/dev/null
        ;;
        install_app)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'   ${dbname}  -e "select app,count(*) from instance_app group by app;"  2>/dev/null
        ;;
        instance_count)
        /data/service/database/mysql/bin/mysql -uroot -p'haima123outfox'   ${dbname}  -e "select count(*) from instance;"  2>/dev/null
        ;;
        *)
        echo "USAGE:$0 [pre|prod] [ota_version|instance_status|service_info]"
        echo "USAGE:$0 [pre|prod] app_info packageName"
        ;;
esac

hostname
