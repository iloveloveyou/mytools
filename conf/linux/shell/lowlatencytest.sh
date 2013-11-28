#!/bin/bash
#测试结果都会保存在/root/result/下以测试开始时间+dir_suffix命名的文件夹中。
#低延迟测试
VAILD_IP=1
ping -c 1 $1 > /dev/null 2>&1
if [ $? -ne 0 ];
	then
		VAILD_IP=0;
fi

ping -c 1 $2 > /dev/null 2>&1
if [ $? -ne 0 ];
	then
		VAILD_IP=0;
fi


if [ "$3" = "" ];
then
	messagesize=64;
else
	messagesize=$3;
fi

if [ "$4" = "" ];
then
	testtime=120;
else
	testtime=$4;
fi

if [ $VAILD_IP = 0 ] || [ $messagesize -lt 12 ] || [ $testtime -lt 1 ];
	then
		echo "arguments is invalid.";
		echo "Usage: testscript <server ip> <client ip> [message size] [test time] [dir_suffix]";
		echo "message size, test time and dir_suffix is optional.";
		echo "default message size is 64 byte(min 12 byte)";
		echo "default test time is 120s";
		echo "Message size ， test time 是可选项，如果不填则默认用64字节message size，120s作为test time. "
		echo "dir_suffix用作分类测试结果文件夹的后缀，方便用户归档测试结果";
		exit 1
fi

waittime=5

ssh $1 -C "kill \`ps -C netserver -o pid --no-headers\`" > /dev/null 2>&1
ssh $2 -C "kill \`ps -C netserver -o pid --no-headers\`" > /dev/null 2>&1
ssh $1 -C "kill \`ps -C sockperf -o pid --no-headers\`" > /dev/null 2>&1
ssh $2 -C "kill \`ps -C sockperf -o pid --no-headers\`" > /dev/null 2>&1

################### NETPERF test#########################
#start netserver on $1
ssh $1 -C 'netserver -D -f ' &

#create result dir
RESULT_DIR_1=/root/result/`date +%Y%m%d``date +%H``date +%M`$5/srv$1_cli$2
RESULT_DIR_2=/root/result/`date +%Y%m%d``date +%H``date +%M`$5/srv$2_cli$1
mkdir $RESULT_DIR_1 -p
sleep 2

############
#test cmd
############
ssh $2 -C "netperf -n 16 -H $1 -c -C -t UDP_RR -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_1/netperf_UDP_RR
sleep $waittime
ssh $2 -C "netperf -n 16 -H $1 -c -C -t TCP_RR -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_1/netperf_TCP_RR
#ssh $2 -C "netperf -n 16 -H $1 -c -C -t UDP_STREAM -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_1/netperf_UDP_RR
#ssh $2 -C "netperf -n 16 -H $1 -c -C -t TCP_STREAM -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_1/netperf_TCP_RR
sleep $waittime
#kill netserver on $1
ssh $1 -C "kill \`ps -C netserver -o pid --no-headers\`"


#start netserver on $2
ssh $2 -C 'netserver -D -f' &

#create result dir
mkdir $RESULT_DIR_2 -p
sleep 2

############
#test cmd
############
ssh $1 -C "netperf -n 16 -H $2 -c -C -t UDP_RR -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_2/netperf_UDP_RR
sleep $waittime
ssh $1 -C "netperf -n 16 -H $2 -c -C -t TCP_RR -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_2/netperf_TCP_RR
#ssh $1 -C "netperf -n 16 -H $2 -c -C -t UDP_STREAM -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_2/netperf_UDP_RR
#ssh $1 -C "netperf -n 16 -H $2 -c -C -t TCP_STREAM -l $testtime -T 2,2 -v2 -- -m $messagesize -k P50_LATENCY,P90_LATENCY,P99_LATENCY,MEAN_LATENCY,STDDEV_LATENCY,MAX_LATENCY" >> $RESULT_DIR_2/netperf_TCP_RR
sleep $waittime

#kill netserver on $2
ssh $2 -C "kill \`ps -C netserver -o pid --no-headers\`"




###################SOCKPERF test#########################

ssh $1 -C "sockperf sr -i $1" &

sleep 2

ssh $2 -C "sockperf pp -i $1 -m $messagesize -t $testtime" >> $RESULT_DIR_1/sockperf_UDP_PP
#ssh $2 -C "sockperf tp -i $1 -m $messagesize -t $testtime" >> $RESULT_DIR_1/sockperf_UDP_PP
sleep $waittime

ssh $1 -C "kill \`ps -C sockperf -o pid --no-headers\`"




ssh $1 -C "sockperf sr -i $1 --tcp" &

sleep 2

ssh $2 -C "sockperf pp -i $1 -m $messagesize -t $testtime --tcp" >> $RESULT_DIR_1/sockperf_TCP_PP
#ssh $2 -C "sockperf tp -i $1 -m $messagesize -t $testtime --tcp" >> $RESULT_DIR_1/sockperf_TCP_PP
sleep $waittime

ssh $1 -C "kill \`ps -C sockperf -o pid --no-headers\`"




ssh $2 -C "sockperf sr -i $2" &

sleep 2

ssh $1 -C "sockperf pp -i $2 -m $messagesize -t $testtime" >> $RESULT_DIR_2/sockperf_UDP_PP
#ssh $1 -C "sockperf tp -i $2 -m $messagesize -t $testtime" >> $RESULT_DIR_2/sockperf_UDP_PP
sleep $waittime


ssh $2 -C "kill \`ps -C sockperf -o pid --no-headers\`"




ssh $2 -C "sockperf sr -i $2 --tcp" &

sleep 2

ssh $1 -C "sockperf pp -i $2 -m $messagesize -t $testtime --tcp" >> $RESULT_DIR_2/sockperf_TCP_PP
#ssh $1 -C "sockperf tp -i $2 -m $messagesize -t $testtime --tcp" >> $RESULT_DIR_2/sockperf_TCP_PP
sleep $waittime


ssh $2 -C "kill \`ps -C sockperf -o pid --no-headers\`"
exit 0
