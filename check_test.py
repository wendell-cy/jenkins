import sys
from pyzabbix import ZabbixAPI

zapi = ZabbixAPI("http://123.207.149.73:8025/api_jsonrpc.php")
zapi.login("admin", "rddjlwv[DFf3af1derbj")
print("Connected to Zabbix API Version %s" % zapi.api_version())
data1=zapi.hostinterface.get(output="extend")
data2=zapi.host.get(output="extend")
for h in data1:
    if "10.177.65." in h["ip"]:
	for y in data2:
		if h["hostid"] == y["hostid"]:
			print y["host"]+","+h["ip"]
