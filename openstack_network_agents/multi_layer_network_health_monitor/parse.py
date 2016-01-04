#!/usr/bin/python
from __future__ import print_function
import os,re,subprocess

#open("/root/nagarjun/multi_layer_network_health_monitor/t2.txt", 'w').close()
oid_if = {} 
server_ip="172.25.30.2"
interface_list="eno1\|eno2"
cmd="snmpwalk -v 1 localhost -c public ifdescr | grep '"+interface_list+"' | cut -d'.' -f2 | cut -d' ' -f1,4 > /root/nagarjun/multi_layer_network_health_monitor/oid_if.txt"
#print(cmd)
os.system(cmd)
#os.system("snmpwalk -v 1 localhost -c public ifdescr | grep 'eno1\|eno2' | cut -d'.' -f2 | cut -d' ' -f1,4 > /root/nagarjun/multi_layer_network_health_monitor/oid_if.txt")   # genrate the oid and interface pair into files
infile_4 = open('/root/nagarjun/multi_layer_network_health_monitor/oid_if.txt','r') 
file_4= infile_4.readlines()
for d in file_4:
	oid,interface = [p.strip() for p in d.split(' ')]
      	oid_if.setdefault(oid,interface)
######
	#print oidinterface
	#print oid_if
#	print ("!!!!!!!!!!!!!!!!!!!!!!!")

f = open('/root/nagarjun/multi_layer_network_health_monitor/interface_metric_list.txt')
for line1 in iter(f):
	for k,v in oid_if.iteritems():
		
		line1=line1.rstrip('\n')
#		line1=line1.rstrip('\n')
		cmd1 = "snmpwalk -v 1 localhost -c public " + line1 + "| grep " + line1+"."+k + "| cut -d':' -f4 | cut -d' ' -f2| awk 'NR==1'"
		#print (cmd1)
		value1=os.popen(cmd1).read()
		print ("%s_%s=%s" % (line1,v,value1),end="")
		#log1 = open("/root/nagarjun/multi_layer_network_health_monitor/t2.txt", "a")
		#print ("%s=%s=%s" % (line1,v,value1), file = log1,end="") 	
f.close()
q = open('/root/nagarjun/multi_layer_network_health_monitor/server_metric_list.txt')
for line2 in iter(q):
                line2=line2.rstrip('\n')
                cmd2 = "snmpwalk -v 1 localhost -c public " + line2 + "| grep " + line2+".0 | cut -d':' -f4 | cut -d' ' -f2"
                value2=os.popen(cmd2).read()
               	print ("%s_%s=%s" % (line2,server_ip,value2),end="")
		#log2 = open("/root/nagarjun/multi_layer_network_health_monitor/t2.txt", "a")
#		for line in iter(log2):
#			line=line.rstrip('\n')
		#print ("%s=%s=%s" % (line2,server_ip,value2), file = log2,end="")
q.close()
#p = open('/root/nagarjun/multi_layer_network_health_monitor/t1.txt')
#for line in iter(p):
#	line=line.rstrip('\n')
#	print ("%s.%s= %s" % (line1,v,value1))
#p.close()
