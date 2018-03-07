#!/bin/bash
count=$#
if [ $count -eq 3 ];then
BID=$1
TYPE=$2
packageName=$3
else
	echo "Usage:$0  BID ClientType packageName pool_count"
	echo "              BID: xiamatest01|8F3BB845AD4|D4F92FE4CFC"
	echo "              ClientType: Android|Web|IOS|Mac|IOS_H5|AndroidH5|TV"
	echo "              packageName: com.tencent.tmgp.sgame"
	echo "              pool_count: pooled instance count"
	exit 0
fi
curl -d "
    {
            \"operation\":\"com.haima.cloudplayer.servicecore.streamingPoolService.changeApkType\",
            \"args\":[
                {
                        \"@type\":\"com.haima.cloudplayer.servicecore.domain.streamingpool.StreamingPoolKey\",
                        \"interfaceId\":2,
                        \"bid\":\"$BID\",
                        \"envType\":\"Formal\",
                        \"product\":\"$packageName\",
                        \"clientType\":\"$TYPE\"
                    },
                    \"PooledWithRestart\"
            ]
    }
    " -H "Content-Type: application/json" http://10.177.0.7:8111/rest/api/v2
