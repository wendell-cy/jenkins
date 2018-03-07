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
SQL='db.appInfo.update({packageName:"com.ironhidegames.android.ironmarines",majorVersion:101,minorVersion:3,"obbHpkNfsDir":{$exists:false}},{$set:{"obbHpkNfsDir":"/data/nfs/obb/com.ironhidegames.android.ironmarines/101/"}})'
$CMD --eval "$SQL"
hostname
