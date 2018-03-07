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
        if [ ! -z $1 ];then
            if [ ! -z $2 ];then
                if [ ! -z $3 ];then
                    args=3
                else
                    args=2
                fi
            else
                args=1
            fi
        else
               echo "USAGE:$0 pkgname major minor"
                exit 0

        fi
        case  $args in
                1)
                        pkgname=$1
                        SQL="packageName:\"$pkgname\""
                ;;
                2)
                        pkgname=$1
                        major=$2
                        SQL="packageName:\"$pkgname\",majorVersion:$major"
                ;;
                3)
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
        if [ $type == "check" ];then
                echo "db.appInfo.find({$SQL}).forEach(printjson)"
        elif [ $type == "count" ];then
		if [ $args -eq 1 -o $args -eq 2  -o $args -eq 3 ];then
			echo "db.appInfo.find({$SQL}).count()"
		elif [ $args -eq 0 ];then
			echo "db.appInfo.find({}).count()"
		else
        		echo  "[Error]: too many parameters"
		fi
        elif [ $type == "remove" ];then
                $DumpCMD 
        #       if [ $argcount -eq 3 -o $argcount -eq 1 ];then
                if [ $args -eq 3 ];then
                        echo "db.appInfo.remove({$SQL})"
                else
                        echo "USAGE:$0 remove pkgname major minor"
                fi
        else
                exit 1
        fi
}
$CMD  --eval "$(SQL_check $pkgname $major $minor)" |grep -v "MongoDB shell version"|grep -v "cloudplayer_controller_idcprod"
hostname
