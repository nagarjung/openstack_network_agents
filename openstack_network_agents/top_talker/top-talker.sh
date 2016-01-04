#!/bin/bash
#file=`ls -Art  | head -1`
#/usr/local/bin/nfdump -M /root/netflow/ovs-logs/compute-1-br-int:compute-2-br-int -R $file -o extended -s record/bytes -A srcip -n 10  > /root/netflow/ovs-dumps/top-talker.txt
#log_directory="/root/netflow/logs/poweredge-1/"
#file=`ls -Art $log_directory_1 | tail -60 | head -1`
file=`ls -Art /root/netflow/logs/poweredge-1/ | tail -3000 | head -1`
#file=`ls -Art /root/netflow/logs/poweredge-1/ | head -2000`
#/usr/local/bin/nfdump -R $log_directory/$file -A inif,srcip -s record/bytes | tail -n +4 | head -n -4 > /root/netflow/dumps/top-talker.txt
nfdump -M /root/netflow/logs/poweredge-1:poweredge-3 -R $file -A inif,srcip -s record/bytes | tail -n +4 | head -n -4 > /root/netflow/dumps/top-talker.txt
#nfdump -R $log_directory_1/$file -A inif,srcip -s record/bytes | tail -n +4 | head -n -4 > /root/netflow/dumps/top-talker.txt
#tsdb=52.8.42.159
tsdb=175.126.104.46
metric1=net.top.talker.bytes
metric2=net.top.talker.packets
metric3=net.top.talker.throughput
metric4=net.top.talker.flows
metric5=net.longest.flow
metric6=net.flowspersec
metric7=net.top.talker.bytes.storage
metric8=net.top.talker.throughput.storage
large=0
#net_id="f098007425947688cc2c9d17a2cbbfe"
while read data; do
	#echo $data
	large=`echo $data | cut --d=" " -f3`	
	#echo $large
	of_port=`echo $data | cut --d=" " -f4`
	src_ip=`echo $data | cut --d=" " -f5`
	
	#var1=`echo $data | cut --d=" " -f5`
        #from=`echo $var1 | cut --d=":" -f1`
	#echo $from
        #src_port=`echo $var1 | cut --d=":" -f2`
        #proto=`echo $data | cut --d=" " -f4`
        #var2=`echo $data | cut --d=" " -f7`
        #to=`echo $var2 | cut --d=":" -f1`
        #dest_port=`echo $var2 | cut --d=":" -f2`
        packet=`echo $data | cut --d=" " -f6`
        byte=`echo $data | cut --d=" " -f7`
        #pps=`echo $data | cut --d=" " -f12`
        bps=`echo $data | cut --d=" " -f8`
        #bpp=`echo $data | cut --d=" " -f14`
        flows=`echo $data | cut --d=" " -f10`
	now=$(($(date +%s%N)/1000000000))
	unit=`echo $data | cut --d=" " -f8`	
	line=`awk -F " " -v var="$of_port" '$1 == var' /root/netflow/dumps/final.txt`
	#echo $line
	net_id=`echo $line | cut --d=" " -f2`
	ten_id=`echo $line | cut --d=" " -f3`
	vswitch=`echo $line | cut --d=" " -f4`
	#if [ $i -le $NUM ] && [ $i -gt 3 ] && [ ! -z "$from" ];
	#then
		if [ "$unit" == "M"  ];
        	then
                	byte=`echo "$byte * 1000000" | bc -l `
			bps=`echo $data | cut --d=" " -f9`
			flows=`echo $data | cut --d=" " -f11`
        	fi
		
		echo "put $metric1 $now $byte src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch" | nc -w 30 $tsdb 4343
                #echo "put $metric2 $now $packet src=$src_ip net_id=$net_id tenant_id=$ten_id" | nc -w 30 $tsdb 4343
                echo "put $metric3 $now $bps src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch" | nc -w 30 $tsdb 4343
                #echo "put $metric4 $now $flows src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch" | nc -w 30 $tsdb 4343
		#echo "put $metric5 $now $large src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch" | nc -w 30 $tsdb 4343		
		echo "put $metric7 $now $byte src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch" | nc -w 30 $tsdb 4343
		echo "put $metric8 $now $bps src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch" | nc -w 30 $tsdb 4343		

		echo "$metric1 $now $byte src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"
		#echo "$metric2 $now $packet src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"
		echo "$metric3 $now $bps src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"
		#echo "$metric4 $now $flows src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"
		#echo "$metric5 $now $large src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"
		echo "$metric7 $now $byte src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"	
		echo "$metric8 $now $bps src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"

		large=`echo $large | cut --d='.' -f1`
        	time_value=$(($large / 1000))
		flowspersec=$((flows / time_value))
		echo "$metric6 $now $flowspersec src=$src_ip net_id=$net_id tenant_id=$ten_id vswitch=$vswitch"
		echo "put $metric6 $now $flowspersec src=$src_ip net_id=$net_id" | nc -w 30 $tsdb 4343	
		#echo "-----------<<<<<<<<--------------Next Top-Talker------------->>>>>>>>--------"
	#fi
done < "/root/netflow/dumps/top-talker.txt"

