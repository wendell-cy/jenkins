#!/bin/bash
D=`date +%Y%m%d%H%M`
bakbase=/data/backup/mongodata
bakdir=$bakbase/$D
argcount=$#
CMD='/data/service/mongodb-3.2.6/bin/mongo cloudplayer_controller_idcprod -u admin -p Yw2017Mongo '
DumpCMD="/data/service/mongodb-3.2.6/bin/mongodump  -d cloudplayer_controller_idcprod -u admin -p Yw2017Mongo -o $bakdir "
if [ ! -z $1 ];then
        type=$1
fi
pkgname=$2
major=$3
minor=$4
SQL_check() {
        case  $argcount in
                4)
                        pkgname=$1
                        major=$2
                        minor=$3
                        SQL="packageName:\"$pkgname\",majorVersion:$major,minorVersion:$minor"
                ;;
                *)
                        echo "usage:$0 pkgname "
                        exit 0
                ;;
        esac
        if [ $type == "delete" ];then
                echo "db.appInfo.find({$SQL}).forEach(printjson)"
 #               echo "db.getCollection('appInfo').update({$SQL},{$unset:{\"unify\":\"\"}},false,true)"
        else
                exit 1
        fi
}
if [ $argcount -lt 2 ];then
        echo  "[Error]: Not enough parameters"
else
 $CMD  --eval "$(SQL_check $pkgname $major $minor)" 
fi
hostname
