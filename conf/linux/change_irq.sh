#!/bin/bash
#PS：记得修改网卡中断号，别直接拿来用哦
ethtool -K eth0 gro off
ethtool -K eth1 gro off
ethtool -K eth2 gro off
ethtool -K eth3 gro off
service irqbalance stop
chkconfig irqbalance off
cat /proc/irq/{84,85,86,87,88,89,90,91,92,93}/smp_affinity
echo 1 > /proc/irq/84/smp_affinity
echo 2 > /proc/irq/85/smp_affinity
echo 4 > /proc/irq/86/smp_affinity
echo 8 > /proc/irq/87/smp_affinity
echo 10 > /proc/irq/88/smp_affinity
echo 20 > /proc/irq/89/smp_affinity
echo 40 > /proc/irq/90/smp_affinity
echo 80 > /proc/irq/91/smp_affinity
echo 100 > /proc/irq/92/smp_affinity
echo 200 > /proc/irq/93/smp_affinity
# Enable RPS (Receive Packet Steering)
rfc=4096
cc=$(grep -c processor /proc/cpuinfo)
rsfe=$(echo $cc*$rfc | bc)
sysctl -w net.core.rps_sock_flow_entries=$rsfe
for fileRps in $(ls /sys/class/net/eth*/queues/rx-*/rps_cpus)
do
	echo fff > $fileRps
done
for fileRfc in $(ls /sys/class/net/eth*/queues/rx-*/rps_flow_cnt)
do
	echo $rfc > $fileRfc
done
tail /sys/class/net/eth*/queues/rx-*/{rps_cpus,rps_flow_cnt}
chmod +x /opt/sbin/change_irq.sh
echo "/opt/sbin/change_irq.sh" >> /etc/rc.local
