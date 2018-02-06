#!/bin/sh
#˵��
show_usage="args: [-l , -r , -b , -w]\
                                  [--local-repository=, --repository-url=, --backup-dir=, --webdir=]"
#����
# ���زֿ�Ŀ¼
opt_localrepo=""

# git�ֿ�url
opt_url=""

# ����Ŀ¼
opt_backupdir=""

# webĿ¼
opt_webdir=""

GETOPT_ARGS=`getopt -o l:r:b:w: -al local-repository:,repository-url:,backup-dir:,webdir: -- "$@"`
eval set -- "$GETOPT_ARGS"
#��ȡ����
while [ -n "$1" ]
do
        case "$1" in
                -l|--local-repository) opt_localrepo=$2; shift 2;;
                -r|--repository-url) opt_url=$2; shift 2;;
                -b|--backup-dir) opt_backupdir=$2; shift 2;;
                -w|--webdir) opt_webdir=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

if [[ -z $opt_localrepo || -z $opt_url || -z $opt_backupdir || -z $opt_webdir ]]; then
        echo $show_usage
        echo "opt_localrepo: $opt_localrepo , opt_url: $opt_url , opt_backupdir: $opt_backupdir , opt_webdir: $opt_webdir"
        exit 0
fi

# ����ű�����Ŀ¼
scriptdir=`pwd`/jenkinsdeploy/
mkdir -p $scriptdir

# ��ǰ����汾��
currversion=${scriptdir}currentversion.txt

# �ϴβ���汾
lastversion=${scriptdir}lastversion.txt
if [ ! -f "$lastversion" ];then
        echo "" > $lastversion
fi

# git commit��־
gitcommitlog=${scriptdir}gitcommitlog.txt

# �����汾������ļ��б�
difffile=${scriptdir}difffile.txt

#if [ "$repodif" == "" ];then
#        echo "�ֿⱾ��Ŀ¼����Ϊ�գ������뱾�زֿ�Ŀ¼������"
#        exit 1
#fi

# �л������ذ汾��Ŀ¼
cd $opt_localrepo
# ���´���
git pull $opt_url
# ��ȡcommit��־
git log --pretty=format:"%H" > $gitcommitlog

# ��ȡ��ǰcommit�汾
currentcommit=`head -1 $gitcommitlog`
echo "current commit id: $currentcommit"

# ��һ�β����commit id
lastdeployid=`head -1 $lastversion`
echo "lastdeployid: $lastdeployid"

if [ "$lastdeployid" = "" ];then
        lastdeployid=`tail -1 $gitcommitlog`
        echo "lastdeployid: $lastdeployid"
fi

if [ "$lastdeployid" = "$currentcommit" ];then
        echo "���ϴβ���İ汾id��ͬ��$currentcommit���������������"
        exit
fi

# ��ȡ�����汾�������ļ��б�
echo "pwd: `pwd`"
git diff $lastdeployid $currentcommit --name-only > $difffile
echo "git diff $lastdeployid $currentcommit --name-only  $difffile">$scriptdir/log.txt

# ���ݵ�ǰʱ�����ɱ���Ŀ¼
bakversion=`date "+%Y%m%d%H%M"`
bakdir=$opt_backupdir/$bakversion
echo "bakdir: $bakdir"

# ��������Ŀ¼
mkdir -p $bakdir
# �����ļ�,Ҫ�������Ŀ¼�ṹ�����л��������Ŀ¼�������ȡ���Ǿ���Ŀ¼
cd $opt_webdir
cat $difffile | xargs -i -t cp -rf --parents {} $bakdir/

# ����,Ҫ�������Ŀ¼�ṹ�����л��������Ŀ¼�������ȡ���Ǿ���Ŀ¼
cd $opt_localrepo
cat $difffile | xargs -i -t cp -rf --parents {} $opt_webdir/

# ��¼��ǰ����汾��Ϣ
echo $currentcommit >$lastversion

echo "$bakdir">>$scriptdir/backup.txt
