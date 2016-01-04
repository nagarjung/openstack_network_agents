#!/bin/bash
. /root/keystonerc_admin
vm_security_group="default"
metric1="net.vmsec.rule.status"
tsdb=175.126.104.46
virsh list | tail -n +3 | head -n -1 | while read line;do

	instance_id=`echo $line | cut --d=" " -f2`
	echo $instance_id
	#nova secgroup-list-rules $vm_security_group | tail -n+4 | head -n -1 | awk '{print $2}' | grep -v "|" > sec_rules.txt
	n1=`nova secgroup-list-rules $vm_security_group | tail -n+4 | head -n -1 | awk '{print $2}' | grep -v "|" | wc -l`
	#echo $n1
	tap_id=`virsh dumpxml $instance_id | grep tap | grep -o -P '(?<=tap).*(?=-)'`
	#echo $tap_id
	#iptables -L -n -v | sed -n "/i$tap_id/,/^$/p" | grep -v "all\|references" | tail -n+2 | head -n-3 | awk '{print $4}' > iptable_rules.txt
	n2=`iptables -L -n -v | sed -n "/i$tap_id/,/^$/p" | grep -v "all\|references" | tail -n+2 | head -n-3 | awk '{print $4}' | wc -l`
	#echo $n2
	now=$(($(date +%s%N)/1000000000))
	if [ $n1 -eq $n2 ];
	then
		echo "No changes in the rules"
		value=0
		echo "put $metric1 $now $value instance=$instance_id" | nc -w 30 $tsdb 4343
		echo "$metric1 $now $value instance=$instance_id"
	else
		value=1
		echo "put $metric1 $now $value instance=$instance_id" | nc -w 30 $tsdb 4343
		echo "$metric1 $now $value instance=$instance_id"
		echo "Instance $instance_id security rules are changed"
		curl -XPOST 'http://12.23.78.237:9200/security/rules/' -d "{
                        'instance_id' : '$instance_id',
                        'message' : 'Instance $instance_id security rules are changed'
                }"
		
	fi 
	count=`iptables -L -n -v | sed -n "/i4d85402c/,/^$/p" | tail -n+3 | head -1 | wc -l`
	if [ $count -eq 0 ];
	then
		echo "IPTable Rules are flushed for the instance id $instance_id"
		value=1
		echo "put $metric1 $now $value instance=$instance_id" | nc -w 30 $tsdb 4343
                echo "$metric1 $now $value instance=$instance_id"
		curl -XPOST 'http://12.23.78.237:9200/security/rules/' -d "{
 		   	'instance_id' : '$instance_id',
    			'message' : 'IPTable Rules are flushed for the instance id $instance_id'
		}"
	#else
		#echo "IPTable Rules are not flushed"	
	fi
	var1=`iptables -L -n -v | sed -n "/i$tap_id/,/^$/p" | grep "neutron-openvswi-sg-fallback"`
	ingress_packet_count=`echo $var1 | cut --d=" " -f1`
	var2=`iptables -L -n -v | sed -n "/o$tap_id/,/^$/p" | grep "neutron-openvswi-sg-fallback"`
	egress_packet_count=`echo $var2 | cut --d=" " -f1`
	echo " Input Chain Packet count = $ingress_packet_count"
	echo " Output Chain Packet count = $egress_packet_count"
done
