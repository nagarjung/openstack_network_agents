#!/usr/bin/python
import os,time,socket
import potsdb
i_f_eno1="eno1"
i_f_eno2="eno2"
server_ip="172.25.30.2"
#server_ip="172.25.29.105"
hostname = os.uname()[1]
os.system('python /root/nagarjun/multi_layer_network_health_monitor/parse.py > /root/nagarjun/multi_layer_network_health_monitor/t1.txt')
time.sleep(60)
os.system('python /root/nagarjun/multi_layer_network_health_monitor/parse.py > /root/nagarjun/multi_layer_network_health_monitor/t2.txt')
metric_value_1 = {}
metric_value_2 = {}
infile_1 = open('t1.txt','r')
infile_2 = open('t2.txt','r')

file_1= infile_1.readlines()
file_2= infile_2.readlines()

for i, j in zip(file_1, file_2):
	metric_1, value_1 = [a.strip() for a in i.split('=')]
	metric_2, value_2 = [b.strip() for b in j.split('=')]
	metric_value_1.setdefault(metric_1,value_1)
	metric_value_2.setdefault(metric_2,value_2)

#print "Dictionary 1=",metric_value_1,"\n"
#print "Dictionary 2=",metric_value_2,"\n"

def cal(a1,e1,a2,e2):
	#print a1,e1,a2,e2
	if(a1 == a2):
		#print "values did not change"
		return 0
	else:
		percent=(float((float(int(e2) - int(e1))) /  (float(int(a2) - int(a1)))) * 100 )
		return percent

def ifspeed_cal(in_packet,out_packet,ifspeed):
	print "Inoctets=",in_packet,"Outoctets=",out_packet,"ifspeed=",ifspeed
	link_util=(((int(out_packet) - int(in_packet)) / (int(ifspeed))))
	return link_util

link_util=ifspeed_cal(metric_value_2.get('ifInOctets_eno1'),metric_value_2.get('ifOutOctets_eno1'),metric_value_2.get('ifSpeed_eno1'))
print "Link Utilization %=",link_util

in_packet_error_eno1=cal(metric_value_1.get('ifInOctets_eno1'),metric_value_1.get('ifInErrors_eno1'),metric_value_2.get('ifInOctets_eno1'),metric_value_2.get('ifInErrors_eno1'))
#print "Incoming Packet Error % =",in_packet_error_eno1,"\n"

in_packet_error_eno2=cal(metric_value_1.get('ifInOctets_eno2'),metric_value_1.get('ifInErrors_eno2'),metric_value_2.get('ifInOctets_eno2'),metric_value_2.get('ifInErrors_eno2'))
#print "Incoming Packet Error % =",in_packet_error_eno2,"\n"

out_packet_error_eno1=cal(metric_value_1.get('ifOutOctets_eno1'),metric_value_1.get('ifOutErrors_eno1'),metric_value_2.get('ifOutOctets_eno1'),metric_value_2.get('ifOutErrors_eno1'))
#print "Outgoing Packet Error % =",out_packet_error_eno1,"\n"

out_packet_error_eno2=cal(metric_value_1.get('ifOutOctets_eno2'),metric_value_1.get('ifOutErrors_eno2'),metric_value_2.get('ifOutOctets_eno2'),metric_value_2.get('ifOutErrors_eno2'))
#print "Outgoing Packet Error % =",out_packet_error_eno2,"\n"

in_packet_drop_eno1=cal(metric_value_1.get('ifInOctets_eno1'),metric_value_1.get('ifInDiscards_eno1'),metric_value_2.get('ifInOctets_eno1'),metric_value_2.get('ifInDiscards_eno1'))
#print "Incoming Packet Drop % =",in_packet_drop_eno1,"\n"

in_packet_drop_eno2=cal(metric_value_1.get('ifInOctets_eno2'),metric_value_1.get('ifInDiscards_eno2'),metric_value_2.get('ifInOctets_eno2'),metric_value_2.get('ifInDiscards_eno2'))
#print "Incoming Packet Drop % =",in_packet_drop_eno2,"\n"

out_packet_drop_eno1=cal(metric_value_1.get('ifOutOctets_eno1'),metric_value_1.get('ifOutDiscards_eno1'),metric_value_2.get('ifOutOctets_eno1'),metric_value_2.get('ifOutDiscards_eno1'))
#print "Outgoing Packet Drop % =",out_packet_drop_eno1,"\n"

out_packet_drop_eno2=cal(metric_value_1.get('ifOutOctets_eno2'),metric_value_1.get('ifOutDiscards_eno2'),metric_value_2.get('ifOutOctets_eno2'),metric_value_2.get('ifOutDiscards_eno2'))
#print "Outgoing Packet Drop % =",out_packet_drop_eno2,"\n"


def search(values, searchFor):
	for k in values:
  		if searchFor in k:
#			return k,values.get(k)
			list_1=k.split("_")
			#print "list is",list_1[0],list_1[1]
			list_1[0] = "net."+list_1[0]
			#print "metric=%s value=%s server_ip=%s" % (list_1[0],values.get(k),list_1[1])
#			push_server_metric(list_1[0],values.get(k),list_1[1])
search(metric_value_2,"tcp")


def server_tcp_metric(s1,s2):
	list_tcp = []
	for (key1, value1),(key2,value2) in zip(metric_value_1.iteritems(),metric_value_2.iteritems()):   # iter on both keys and values
		if key1.startswith(s1) or key1.startswith(s2):
    			#print key1, value1
			#print key2, value2
			list_tcp.extend([value1,value2])
	return list_tcp		


#metrics = potsdb.Client('175.126.103.50', port=4343,qsize=1000, host_tag=True, mps=100, check_host=True)
list_tcp = []
list_tcp = server_tcp_metric('tcpInSegs','tcpInErrs')
#print list_tcp1
in_tcp_seg_error=cal(list_tcp[0],list_tcp[2],list_tcp[1],list_tcp[3])
#print "Incoming tcp segment errors eno1% =",in_tcp_seg_error,"\n"

list_tcp = server_tcp_metric('tcpOutSegs','tcpOutRsts')
	#print list_tcp
out_tcp_resets=cal(list_tcp[0],list_tcp[2],list_tcp[1],list_tcp[3])
#print "Percent of outgoing tcp reset segments =",out_tcp_resets,"\n"

list_tcp = server_tcp_metric('tcpOutSegs','tcpRet')
	#print list_tcp
percent_retrans=cal(list_tcp[0],list_tcp[2],list_tcp[1],list_tcp[3])
#print "Percent of retansmission =",percent_retrans,"\n"

list_tcp = server_tcp_metric('ipInRec','ipReasm')
	#print list_tcp
in_frag_percent=cal(list_tcp[0],list_tcp[2],list_tcp[1],list_tcp[3])
#print "Incoming ip fragment % =",in_frag_percent,"\n"

list_tcp = server_tcp_metric('ipOut','ipFrag')
	#print list_tcp
out_frag_percent=cal(list_tcp[2],list_tcp[0],list_tcp[3],list_tcp[1])
#print "Incoming tcp segment errors eno1% =",out_frag_percent,"\n"

#push_tcp_metric

metric_eno1 = { 'net.in_packet.drop' : in_packet_drop_eno1,
        'net.out_packet.drop' : out_packet_drop_eno1,
        'net.in_packet.error' : in_packet_error_eno1,
        'net.out_packet.error' : out_packet_error_eno1,
        'net.qlen' : metric_value_2.get('ifOutQLen_eno1'),
}

metric_eno2 = { 'net.in_packet.drop' : in_packet_drop_eno2,
        'net.out_packet.drop' : out_packet_drop_eno2,
        'net.in_packet.error' : in_packet_error_eno2,
        'net.out_packet.error' : out_packet_error_eno2,
        'net.qlen' : metric_value_2.get('ifOutQLen_eno2'),
}

metric_server_t1 = { 'net.tcp.in_segment.error' : in_tcp_seg_error,
	'net.tcp.out_segment.reset': out_tcp_resets ,
	'net.retrans': percent_retrans,
	'net.in_ip_fragment' : in_frag_percent,
	'net.in_out_fragment': out_frag_percent
	
}

metrics = potsdb.Client('175.126.104.46', port=4343,qsize=1000, host_tag=True, mps=100, check_host=True)
#server related metrics push
def search(values, searchFor):
        for k in values:
                if searchFor in k:
                        #print k,values.get(k),"\n"
#                       return k,values.get(k)
                        list_1=k.split("_")
                        #print "list is",list_1[0],list_1[1]
                        list_1[0] = "net."+list_1[0]
                        print "%s %s %s" % (list_1[0],values.get(k),hostname)
                       	#metrics.send(list_1[0],values.get(k),server_ip=list_1[1])
			metrics.send(list_1[0],values.get(k),host=hostname)
search(metric_value_2,"tcp")

print "\n"

# % server related metrics push 
for key1, value1 in metric_server_t1.iteritems():
        metrics.send(key1, value1, host=hostname)
        print key1,value1,hostname

print "\n"

#interface metrics push
for (key1, value1),(key2,value2) in zip(metric_eno1.iteritems(),metric_eno2.iteritems()):
	metrics.send(key1, value1, host=hostname,interface=i_f_eno1)
	metrics.send(key2, value2, host=hostname,interface=i_f_eno2)
	print key1,value1,hostname,i_f_eno1
	print key2,value2,hostname,i_f_eno2
print "\n"
metrics.send("net.link.util", link_util, host=hostname,interface=i_f_eno1)
print link_util 
metrics.wait()

