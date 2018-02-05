#!/bin/sh
#˵��
show_usage="args: [-b , -w]\
                                  [--backup-dir=, --webdir=]"
#����

# ����Ŀ¼
opt_backupdir=""

# webĿ¼
opt_webdir=""

GETOPT_ARGS=`getopt -o b:w: -al backup-dir:,webdir: -- "$@"`
eval set -- "$GETOPT_ARGS"
#��ȡ����
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

# ����ű�����Ŀ¼
scriptdir=`pwd`/jenkinsdeploy/
mkdir -p $scriptdir

# ���ݼ�¼ 
backupfile=$scriptdir/backup.txt
# ��ȡ��һ�α��ݵļ�¼
bakdir=`tail -1 $backupfile`

if [ "$bakdir" = "" ];then
        echo "�޷���ȡ����Ŀ¼��"
        exit
fi

echo "����Ŀ¼��$bakdir"
echo "webĿ¼��$opt_webdir"

cd $bakdir
cp -rf --parents ./* $opt_webdir/

echo "�ɹ��ع���"