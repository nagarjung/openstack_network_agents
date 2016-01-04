#!/bin/bash
#. /root/keystonerc_admin
tsdb=175.126.104.46
openstack-status | grep "neutron-\|openvswitch-\|nova-\|glance-\|horizon-\|swift-\|ceilometer-\|cinder-" | grep -v "disabled on boot" | while read line;do

#openstack-status | grep -v "disabled on boot" | while read line;do
	#echo $line
	service=`echo $line | cut --d=":" -f1`
	value=`echo $line | cut --d=":" -f2 | cut --d=" " -f2`
	#value="inactive"
	hostname=`hostname`
	now=$(($(date +%s%N)/1000000000))
	status_string="active"
	if [ "$value" == "active" ];
	then
		value=1
	else
		value=0
	fi

	echo "put net.$service.status $now $value host=$hostname service=$service" | nc -w 30 $tsdb 4343
	echo "net.$service.status $now $value host=$hostname service=$service"
done

