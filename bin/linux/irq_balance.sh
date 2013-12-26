#!/bin/bash
#echo 'deadline'>/sys/block/sda/queue/scheduler
#echo '16'> /sys/block/sda/queue/read_ahead_kb
#echo '512'>/sys/block/sda/queue/nr_requests
#echo 'deadline'>/sys/block/sdb/queue/scheduler
#echo '16'> /sys/block/sdb/queue/read_ahead_kb
#echo '512'>/sys/block/sdb/queue/nr_requests

#如果要想提高性能，将IRQ绑定到某个CPU，那么最好在系统启动时，将那个CPU隔离起来，不被scheduler通常的调度。
#可以通过在Linux kernel中加入启动参数
#isolcpus=cpu-list

ethtool -K em1 gro off
service irqbalance stop
chkconfig irqbalance off
cat /proc/irq/{106,107,108,109,110}/smp_affinity
echo 1 > /proc/irq/106/smp_affinity
echo 4 > /proc/irq/107/smp_affinity              
echo 10 > /proc/irq/108/smp_affinity 
echo 40 > /proc/irq/109/smp_affinity  
echo 100 > /proc/irq/110/smp_affinity 

# Enable RPS (Receive Packet Steering)
rfc=4096
cc=$(grep -c processor /proc/cpuinfo)
rsfe=$(echo $cc*$rfc | bc)
sysctl -w net.core.rps_sock_flow_entries=$rsfe
for fileRps in $(ls /sys/class/net/em*/queues/rx-*/rps_cpus)
do
echo fff > $fileRps
done
for fileRfc in $(ls /sys/class/net/em*/queues/rx-*/rps_flow_cnt)
do
echo $rfc > $fileRfc
done
tail /sys/class/net/em*/queues/rx-*/{rps_cpus,rps_flow_cnt}
#echo "/opt/sbin/change_irq.sh" >> /etc/rc.local
