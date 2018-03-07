#!/bin/bash
count=$#
if [ $count -eq 5 ];then
interfaceid=$1
BID=$2
TYPE=$3
packageName=$4
count=$5
else
	echo "Usage:$0 interfaceid BID ClientType packageName pool_count"
	echo "              interfaceid: 南京: 2 ;佛山: 58"
	echo "              BID: xiamatest01|8F3BB845AD4|D4F92FE4CFC"
	echo "              ClientType: Android|Web|IOS|Mac|IOS_H5|AndroidH5|TV"
	echo "              packageName: com.tencent.tmgp.sgame"
	echo "              pool_count: pooled instance count"
	exit 0
fi
curl -d "
    {
            \"operation\":\"com.haima.cloudplayer.servicecore.streamingPoolService.createStreamingPool\",
            \"args\":[
                {
                    \"@type\":\"com.haima.cloudplayer.servicecore.domain.streamingpool.StreamingPoolInfo\",
                    \"poolKey\": {
                        \"@type\":\"com.haima.cloudplayer.servicecore.domain.streamingpool.StreamingPoolKey\",
                        \"interfaceId\":$interfaceid,
                        \"bid\":\"$BID\",
                        \"envType\":\"Formal\",
                        \"product\":\"$packageName\",
                        \"clientType\":\"$TYPE\"
                    },
                    \"maxPooledSize\":$count,
                    \"maxPoolingSize\":5,
                    \"releaseInSeconds\":5,
                    \"apkType\":\"PooledWithRestart\"
                }
            ]
    }
    " -H "Content-Type: application/json" http://10.177.0.7:8111/rest/api/v2

curl -d "
    {
        \"operation\":\"com.haima.cloudplayer.servicecore.streamingPoolService.startAdjust\",
        \"args\":[
            {
                \"@type\":\"com.haima.cloudplayer.servicecore.domain.streamingpool.StreamingPoolKey\",
                \"interfaceId\":$interfaceid,
                \"bid\":\"$BID\",
                \"envType\":\"Formal\",
                \"product\":\"$packageName\",
                \"clientType\":\"$TYPE\"
            }
        ]
    }
    " -H "Content-Type: application/json" http://10.177.0.7:8111/rest/api/v2
