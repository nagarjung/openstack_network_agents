#!/bin/bash
. /root/keystonerc_admin
> /root/nagarjun/tenant/dump.txt
> /root/nagarjun/tenant/final.txt
ovs-ofctl show br-int | grep qvo | awk -F"(" '{print $1}' > /root/nagarjun/tenant/ofport-dump.txt
neutron net-list | grep -v "rally" | awk ' {print $4}' | awk "NR>3" | sed '$d' | grep "Net\|net" > /root/nagarjun/tenant/net_list.txt
#neutron net-list | grep -v "rally" | awk ' {print $4}' | awk "NR>3" | sed '$d' | while read net_name; do
while read net_name; do
	#net_id=`neutron net-show $net_name | sed -n '5p' | awk '{print $4}'`
	#ten_id=`neutron net-show $net_name | sed -n '14p' | awk '{print $4}'`
	var=`neutron net-show $net_name | sed -n '9p;5p;14p' | awk '{print $4}'`
	seg_id=`echo $var | cut --d=" " -f2`
	net_id=`echo $var | cut --d=" " -f1`
	ten_id=`echo $var | cut --d=" " -f3`
	echo "$net_name $seg_id $net_id $ten_id" >> /root/nagarjun/tenant/dump.txt
	#echo $net_name  Network ID= $net_id  Tenant ID= $ten_id
done < /root/nagarjun/tenant/net_list.txt
vswitch=`hostname`
while read ofport; do
instance_port=`ovs-ofctl show br-int | grep qvo | awk '{print $1}' | grep -E "$ofport.qvo" | cut -d'(' -f2 | cut -d')' -f1`
instance_tag=`ovs-vsctl list port | grep -A 5 $instance_port | grep tag | cut -d':' -f2 | cut -d' ' -f2`
tunnel_id_hex=`ovs-ofctl dump-flows br-tun | grep dl_vlan=$instance_tag | cut -d':' -f2 | cut -d',' -f1 | cut -c 3-`
tunnel_id=`echo $((16#$tunnel_id_hex))`
#echo "Tunnel id $tunnel_id"
#network_id=`cat /root/nagarjun/tenant/dump.txt  | grep $tunnel_id | cut -d' ' -f3`
network_id=`cat /root/nagarjun/tenant/dump.txt  | awk -v var="$tunnel_id" -F' ' '$2==var' | cut -d' ' -f3`
#tenant_id=`cat /root/nagarjun/tenant/dump.txt  | grep $tunnel_id | cut -d' ' -f4`
tenant_id=`cat /root/nagarjun/tenant/dump.txt  | awk -v var="$tunnel_id" -F' ' '$2==var' | cut -d' ' -f4`
#echo "$ofport $network_id $tenant_id $vswitch" >> /root/nagarjun/tenant/final.txt
echo "$ofport $network_id $tenant_id $vswitch" >> /root/nagarjun/tenant/final.txt

done < /root/nagarjun/tenant/ofport-dump.txt
#scp -i /root/sentilo_n42.pem /root/nagarjun/tenant/final.txt root@52.8.42.159:/root/netflow/dumps/

topTalkerIp=175.126.103.49
username=root
password=son123!
#sshpass -p $password scp /root/nagarjun/tenant/final.txt $username@$topTalkerIp:/root/netflow/dumps/
cat /root/nagarjun/tenant/final.txt | sshpass -p $password ssh $username@$topTalkerIp 'cat > /root/netflow/dumps/final.txt'

