#!/bin/sh
#说明
show_usage="args: [-l , -r , -b , -w]\
                                  [--local-repository=, --repository-url=, --backup-dir=, --webdir=]"
#参数
# 本地仓库目录
opt_localrepo=""

# git仓库url
opt_url=""

# 备份目录
opt_backupdir=""

# web目录
opt_webdir=""

GETOPT_ARGS=`getopt -o l:r:b:w: -al local-repository:,repository-url:,backup-dir:,webdir: -- "$@"`
eval set -- "$GETOPT_ARGS"
#获取参数
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

# 部署脚本所在目录
scriptdir=`pwd`/jenkinsdeploy/
mkdir -p $scriptdir

# 当前部署版本号
currversion=${scriptdir}currentversion.txt

# 上次部署版本
lastversion=${scriptdir}lastversion.txt
if [ ! -f "$lastversion" ];then
        echo "" > $lastversion
fi

# git commit日志
gitcommitlog=${scriptdir}gitcommitlog.txt

# 两个版本间差异文件列表
difffile=${scriptdir}difffile.txt

#if [ "$repodif" == "" ];then
#        echo "仓库本地目录不能为空，请输入本地仓库目录参数！"
#        exit 1
#fi

# 切换到本地版本库目录
cd $opt_localrepo
# 更新代码
git pull $opt_url
# 获取commit日志
git log --pretty=format:"%H" > $gitcommitlog

# 获取当前commit版本
currentcommit=`head -1 $gitcommitlog`
echo "current commit id: $currentcommit"

# 上一次部署的commit id
lastdeployid=`head -1 $lastversion`
echo "lastdeployid: $lastdeployid"

if [ "$lastdeployid" = "" ];then
        lastdeployid=`tail -1 $gitcommitlog`
        echo "lastdeployid: $lastdeployid"
fi

if [ "$lastdeployid" = "$currentcommit" ];then
        echo "与上次部署的版本id相同，$currentcommit，不作部署操作。"
        exit
fi

# 获取两个版本间差异的文件列表
echo "pwd: `pwd`"
git diff $lastdeployid $currentcommit --name-only > $difffile
echo "git diff $lastdeployid $currentcommit --name-only  $difffile">$scriptdir/log.txt

# 根据当前时间生成备份目录
bakversion=`date "+%Y%m%d%H%M"`
bakdir=$opt_backupdir/$bakversion
echo "bakdir: $bakdir"

# 创建备份目录
mkdir -p $bakdir
# 备份文件,要保存相对目录结构必须切换到程序根目录，否则获取的是绝对目录
cd $opt_webdir
cat $difffile | xargs -i -t cp -rf --parents {} $bakdir/

# 部署，,要保存相对目录结构必须切换到程序根目录，否则获取的是绝对目录
cd $opt_localrepo
cat $difffile | xargs -i -t cp -rf --parents {} $opt_webdir/

# 记录当前部署版本信息
echo $currentcommit >$lastversion

echo "$bakdir">>$scriptdir/backup.txt
