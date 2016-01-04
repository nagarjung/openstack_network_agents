#!/bin/bash
#ss -in | grep "tcp\|rtt" | grep -v "ipproto" | while read line1; do
#ss -ip | grep "tcp\|rtt\|neutron-l3-agen" | grep -v "ipproto" | sed '1d' | while read line1; do
ss -ip | grep "tcp\|rtt" | grep -v "ipproto" | grep -v "sshd" | sed '1d' | while read line1; do
        read line2

        if [[ $line2 != *"rtt"* ]];
        then
                line1=$line2
                continue
        fi

        src=`echo $line1 | cut -d' ' -f5 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
        dst=`echo $line1 | cut -d' ' -f6 | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
        dst_ser=`echo $line1 | cut -d' ' -f6 | grep -E -o "([\.][0-9]{1,3}[\:][a-z,A-Z]{1,15})" | cut -d':' -f2`
        src_ser=`echo $line1 | cut -d' ' -f7 | grep -E -o "(([\"])[a-z,A-Z,0-9\-]{1,15}([\"]))" | cut -d'"' -f2 | cut -d'"' -f1`
 
	rtt=`echo $line2 | cut -d' ' -f4 | cut -d':' -f2 | cut -d'/' -f1`
        rtt_var=`echo $line2 | cut -d' ' -f4 | cut -d':' -f2 | cut -d'/' -f2`
        
	if [ -z "$src_ser" ];
	then
		src_ser="No-service"
	fi

	if [ -z "$dst_ser" ];
        then
                dst_ser="No-service"

        fi

        
	if [ $src != $dst ] && [ "$dst" == "172.25.30.2" ] || [ "$dst" == "192.168.1.101" ];
        then
    		echo $src $src_ser $dst $dst_ser $rtt $rtt_var

        fi
done
