#!/bin/bash
basedir=/data/Scripts/pooled
type=$1
create_pooled () {
	create_info=`cat $basedir/create_file|grep -v ^#`
	while read line
	do
		info=($line)
		for Ifid in `echo ${info[0]}|tr "," " "`
		do
			for BID in `echo ${info[1]}|tr "," " "`
			do
				for clienttype in `echo ${info[2]}|tr "," " "`
				do
					if [ ${info[5]} -eq 1 ];then
						sh $basedir/pooling_create_restart.sh  $Ifid $BID $clienttype ${info[3]}  ${info[4]}
					else
						sh $basedir/pooling_create.sh  $Ifid $BID $clienttype ${info[3]}  ${info[4]}
					fi
				done
			done
		done
		sleep 5
	done << EOF
$create_info
EOF
}
delete_pooled () {
        create_info=`cat ${basedir}/delete_file |grep -v ^#`
        while read line
        do
                info=($line)
                for Ifid in `echo ${info[0]}|tr "," " "`
                do
                        for BID in `echo ${info[1]}|tr "," " "`
                        do
                                for clienttype in `echo ${info[2]}|tr "," " "`
                                do
                                         sh $basedir/pooling_delete.sh  $Ifid $BID $clienttype ${info[3]}
                                done
                        done
                done
		sleep 5
        done << EOF
$create_info
EOF
}

create_restart_pooled () {
        create_info=`cat $basedir/create_file|grep -v ^#`
        while read line
        do
                info=($line)
                for Ifid in `echo ${info[0]}|tr "," " "`
                do
                        for BID in `echo ${info[1]}|tr "," " "`
                        do
                                for clienttype in `echo ${info[2]}|tr "," " "`
                                do
                                         sh $basedir/pooling_create_restart.sh  $Ifid $BID $clienttype ${info[3]} ${info[4]}
                                done
                        done
                done
                sleep 2
        done << EOF
$create_info
EOF
}

running_restart_pooled () {
        create_info=`cat $basedir/create_file|grep -v ^#`
        while read line
        do
                info=($line)
                for Ifid in `echo ${info[0]}|tr "," " "`
                do
                        for BID in `echo ${info[1]}|tr "," " "`
                        do
                                for clienttype in `echo ${info[2]}|tr "," " "`
                                do
                                         sh $basedir/pooling_restart.sh  $Ifid $BID $clienttype ${info[3]} $1
                                done
                        done
                done
                sleep 5
        done << EOF
$create_info
EOF
}
check_pooled () {
        create_info=`cat $basedir/create_file|grep -v ^#`
        while read line
        do
                info=($line)
                for Ifid in `echo ${info[0]}|tr "," " "`
                do
                        for BID in `echo ${info[1]}|tr "," " "`
                        do
                                for clienttype in `echo ${info[2]}|tr "," " "`
                                do
					echo -en "$Ifid\t$BID\t$clienttype\t${info[3]}\t"
                                         sh $basedir/pooling_check.sh  $Ifid $BID $clienttype ${info[3]} |jq ".response.value"|sed -e "s/^\[//g" -e "s/^\]//g" |jq .streamingPoolInfo.apkType
                                done
                        done
                done
                sleep 5
        done << EOF
$create_info
EOF
}
	
case $type in 
	create)
		create_pooled
	;;
	add)
		echo pooling_add.sh
	;;
	delete)
		delete_pooled
	;;
	create_restart)
		create_restart_pooled 
	;;
	running_restart)
		running_restart_pooled PooledWithRestart
	;;
	running_unrestart)
		running_restart_pooled PooledWithoutRestart
	;;
	check)
		check_pooled
	;;
	*)
		echo "Usage:$0  create|add|delete|create_restart|running_restart"
		echo "create_restart: 创建池化重启"
		echo "running_restart: 将池化转换为池化重启"
	;;
esac
