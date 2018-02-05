#!/bin/sh
#说明
show_usage="args: [-b , -w]\
                                  [--backup-dir=, --webdir=]"
#参数

# 备份目录
opt_backupdir=""

# web目录
opt_webdir=""

GETOPT_ARGS=`getopt -o b:w: -al backup-dir:,webdir: -- "$@"`
eval set -- "$GETOPT_ARGS"
#获取参数
while [ -n "$1" ]
do
        case "$1" in
                -b|--backup-dir) opt_backupdir=$2; shift 2;;
                -w|--webdir) opt_webdir=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

if [[ -z $opt_backupdir || -z $opt_webdir ]]; then
        echo $show_usage
        echo "opt_backupdir: $opt_backupdir , opt_webdir: $opt_webdir"
        exit 0
fi

# 部署脚本所在目录
scriptdir=`pwd`/jenkinsdeploy/
mkdir -p $scriptdir

# 备份记录 
backupfile=$scriptdir/backup.txt
# 获取上一次备份的记录
bakdir=`tail -1 $backupfile`

if [ "$bakdir" = "" ];then
        echo "无法获取备份目录。"
        exit
fi

echo "备份目录：$bakdir"
echo "web目录：$opt_webdir"

cd $bakdir
cp -rf --parents ./* $opt_webdir/

echo "成功回滚。"