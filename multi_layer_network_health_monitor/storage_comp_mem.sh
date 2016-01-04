#!/bin/bash
metric1="proc.uninterupt.process"
metric2="proc.cpu.util"
metric3="proc.cpu.wait.io"
metric4="disk.block.read"
metric5="disk.block.write"
metric6="mem.swap.read"
metric7="mem.swap.write"
metric8="mem.total"
metric9="mem.free"
metric10="mem.total.swap"
metric11="mem.free.swap"
metric12="proc.cpu.load.avg"
metric13="disk.usage.percent"
metric14="proc.num.cpu.cores"
tsdb=175.126.104.46
#tsdb=52.8.42.159

host=`hostname`
count=`free -m | tail -n+2 | wc -l`
if [ $count -eq 2 ];then
	free -m | tail -n+2 | while read line1;do
		read line2
		now=$(($(date +%s%N)/1000000000))
		total_mem=`echo $line1 | cut --d=" " -f2`
		free=`echo $line1 | cut --d=" " -f4`
		cache=`echo $line1 | cut --d=" " -f6`
		free_mem=$(($free +$cache))
		total_swap=`echo $line2 | cut --d=" " -f2`
		free_swap=`echo $line2 | cut --d=" " -f4`
		echo "put $metric8 $now $total_mem host=$host" | nc -w 30 $tsdb 4343
		echo "put $metric9 $now $free_mem host=$host" | nc -w 30 $tsdb 4343
		echo "put $metric10 $now $total_swap host=$host" | nc -w 30 $tsdb 4343
		echo "put $metric11 $now $free_swap host=$host" | nc -w 30 $tsdb 4343
		echo "$metric8 $now $total_mem host=$host"
       	 	echo "$metric9 $now $free_mem host=$host"
        	echo "$metric10 $now $total_swap host=$host"
        	echo "$metric11 $now $free_swap host=$host"
	done
elif [ $count -eq 3 ];then
	free -m | tail -n+2 | while read line1;do
                read line2
		read line3
		now=$(($(date +%s%N)/1000000000))
                total_mem=`echo $line1 | cut --d=" " -f2`
                free_mem=`echo $line2 | cut --d=" " -f3`
                total_swap=`echo $line3 | cut --d=" " -f2`
                free_swap=`echo $line3 | cut --d=" " -f4`
		echo "put $metric8 $now $total_mem host=$host" | nc -w 30 $tsdb 4343
                echo "put $metric9 $now $free_mem host=$host" | nc -w 30 $tsdb 4343
                echo "put $metric10 $now $total_swap host=$host" | nc -w 30 $tsdb 4343
                echo "put $metric11 $now $free_swap host=$host" | nc -w 30 $tsdb 4343
		echo "$metric8 $now $total_mem host=$host"
                echo "$metric9 $now $free_mem host=$host"
                echo "$metric10 $now $total_swap host=$host"
                echo "$metric11 $now $free_swap host=$host"
        done
fi

vmstat -w 2 2 | tail -n+4 | while read line;do
	#echo $line
	cpu_load_avg=`echo $line | cut -d' ' -f1`
	nuip=`echo $line | cut -d' ' -f2`
	si=`echo $line | cut -d' ' -f7`
	so=`echo $line | cut -d' ' -f8`
	#mem_blocks=$((si + so))
	bi=`echo $line | cut -d' ' -f9`	
	bo=`echo $line | cut -d' ' -f10`
	#disk_blocks=$((bi + bo))
	usp=`echo $line | cut -d' ' -f13`
	ksp=`echo $line | cut -d' ' -f14`
	percent_cpu_util=$((usp + ksp))	
	percent_cpu_wait_io=`echo $line | cut -d' ' -f16`
	now=$(($(date +%s%N)/1000000000))
	disk_usage_percent=`df -h | sed -n '2p' | awk '{print $5}' | tr -d '%'`
	num_cores=`nproc`
	#echo "nuip=$nuip si=$si so=$so bi=$bi bp=$bo usp=$usp ksp=$ksp w=$percent_cpu_wait_io"
	echo "put $metric1 $now $nuip host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric2 $now $percent_cpu_util host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric3 $now $percent_cpu_wait_io host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric4 $now $bi host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric5 $now $bo host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric6 $now $si host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric7 $now $so host=$host" | nc -w 30 $tsdb 4343
	#echo "put $metric8 $now $free_ram host=$host" | nc -w 30 $tsdb 4343
	#echo "put $metric9 $now $free_cache host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric12 $now $cpu_load_avg host=$host" | nc -w 30 $tsdb 4343	
	echo "put $metric13 $now $disk_usage_percent host=$host" | nc -w 30 $tsdb 4343
	echo "put $metric14 $now $num_cores host=$host" | nc -w 30 $tsdb 4343
	
	echo "$metric1 $now $nuip host=$host" 
        echo "$metric2 $now $percent_cpu_util host=$host" 
        echo "$metric3 $now $percent_cpu_wait_io host=$host" 
        echo "$metric4 $now $bi host=$host" 
        echo "$metric5 $now $bo host=$host" 
        echo "$metric6 $now $si host=$host" 
        echo "$metric7 $now $so host=$host" 
	echo "$metric12 $now $cpu_load_avg host=$host"	
	echo "$metric13 $now $disk_usage_percent host=$host"
	echo "$metric14 $now $num_cores host=$host"
	#echo "-----------------next line----------------"
done

