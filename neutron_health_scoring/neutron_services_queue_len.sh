#!/bin/bash
tsdb=175.126.104.46
tsdbport=4343
host=`hostname`
#rabbitmqctl list_queues | grep "dhcp_agent\|l3_agent\|q-l3-plugin\|q-plugin\|q-firewall-plugin" | grep -v "fan\|dhcp_agent.$host.$host"| while read var3;do
rabbitmqctl list_queues | awk '/^dhcp_agent.n42-poweredge-5\t|^l3_agent.n42-poweredge-5\t|^q-firewall-plugin\t|^q-l3-plugin\t|^q-plugin\t/' | while read var3;do
                now=$(($(date +%s%N)/1000000000))
                service=`echo $var3 | cut --d=" " -f1 | cut --d="." -f1`
                hostname=`echo $var3 | cut --d=" " -f1 | cut --d="." -f2`
                service_value=`echo $var3 | cut --d=" " -f2`
                echo "put net.$service.queue.len $now $service_value host=$host service=$service" | nc -w 30 $tsdb $tsdbport
                echo "net.$service.queue.len $now $service_value host=$host service=$service"
done

