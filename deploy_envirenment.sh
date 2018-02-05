echo $deploy_envirenment
case $deploy_envirenment in
    deploy)
        echo "deploy: $deploy_envirenment"
        ansible webservers -m script -a "~/bashscript/xxxxxx_deploy.sh --local-repository=/www/test/test --repository-url=git≤÷ø‚µÿ÷∑ --backup-dir=/www/test/bak --webdir=/www/test/www"
        ;;
    rollback)
        echo "rollback: $deploy_envirenment"
        ansible webservers -m script -a '~/bashscript/xxxxxx_rollback.sh --backup-dir=/www/test/bak --webdir=/www/test/www'
        ;;
    *)
    exit
        ;;
esac