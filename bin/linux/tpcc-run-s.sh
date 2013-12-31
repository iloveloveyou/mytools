#!/bin/bash
export LD_LIBRARY_PATH=/usr/local/mysql/lib/ 
#. ~/.bash_profile >/dev/null 2>&1
#DIR=$(pwd)
DIR="/usr/local/tpcc-mysql"

#BASEDIR="/home/data/tpcc"
BASEDIR=$DIR
cd $BASEDIR
mkdir -p $BASEDIR/logs

#exec 3>&1 4>&2 1>> tpcc.log 2>&1

#执行tpcc测试的数据库IP
DBIP='192.168.1.183'
EXEC_P="ssh root@${DBIP} "
STARTER='/etc/init.d/mysqld_multi.server'
MEXEC='/usr/local/mysql/bin/mysql'
DBUSER='replication'
DBPASS='123456'
#DBPORT='3301'
#测试模式：10个仓库
WIREHOUSE=10
DBCODE=1
DBCODE2=`echo $DBCODE|sed 's/ \+/,/g'`
DBNAME="tpcc${WIREHOUSE}"
#数据预热时间：120秒
WARMUP=120
#执行测试时长：1小时
DURING=1000
#测试模式
MODE="MySQL55_innodb_buf9G_8bp_1000dw_ext4_deadline_3disk_raid0"


#初始化测试环境

#if [ -z "`mysqlshow $CONNARG|grep -v grep|grep \"$DBNAME\"`" ] ; then
#fi


CYCLE=0
TOTAL=1
NOW=`date +'%Y%m%d%H%M'`
while [ $CYCLE -lt $TOTAL ]
do

	#测试并发线程：8 ~ 256
	#for THREADS in 8 16 32 64 128 256 
	$EXEC_P "$STARTER start $DBCODE2";echo "startdb and wait 15s";sleep 15;
	for THREADS in 24
	do
		#init 1
		for  DB in $DBCODE 
		do
			DBPORT="330${DB}"
			CONNARG="-h$DBIP -u$DBUSER -p$DBPASS -P$DBPORT "
			$EXEC_P "$MEXEC $CONNARG -e 'drop database $DBNAME'"
			$EXEC_P "/usr/local/mysql/bin/mysqladmin $CONNARG create $DBNAME"
			$EXEC_P "$MEXEC $CONNARG -f $DBNAME <$DIR/create_table.sql"
			$EXEC_P "$MEXEC $CONNARG -f $DBNAME <$DIR/add_fkey_idx.sql"
			$EXEC_P "$MEXEC $CONNARG -e 'reset master'"
		done

		#clean & free
		echo "stop MySQL"
		$EXEC_P "$STARTER stop $DBCODE2";
		sleep 35

		$EXEC_P "echo '3' > /proc/sys/vm/drop_caches"

		echo "start MySQL $DBPORT ..."
		$EXEC_P "$STARTER start $DBCODE2"
		sleep 20

		#load	
		for DB in $DBCODE 
		do
			DBPORT="330${DB}"
			CONNARG="-h$DBIP -u$DBUSER -p$DBPASS -P$DBPORT "
			#$EXEC_P "$STARTER start $DB";sleep 5
			LOAD="$DIR/tpcc_load $DBIP:$DBPORT $DBNAME $DBUSER $DBPASS $WIREHOUSE"
			echo $LOAD;$LOAD
		done
		#开始执行tpcc测试
		#tpcc_start -h server_host -P port -d database_name -u mysql_user -p mysql_password -w warehouses -c connections -r warmup_time -l running_time -i report_interval -f report_file -t trx_file
		for  DB in  $DBCODE
		do
			DBPORT="330${DB}"
			CONNARG="-h$DBIP -u$DBUSER -p$DBPASS -P$DBPORT "
			echo "begin tpcc $DBPORT ..."
			nohup $DIR/tpcc_start $CONNARG -d $DBNAME -w $WIREHOUSE -c $THREADS -r $WARMUP -l $DURING -f ./logs/${NOW}_${DBPORT}_tpcc_${MODE}_${THREADS}_THREADS_${CYCLE}.res >> ./logs/${NOW}_${DBPORT}_tpcc_${MODE}_${THREADS}_THREADS_${CYCLE}.log 2>&1 &
		done

	done # n并发结束
	CYCLE=`expr $CYCLE + 1`
done # 多次测试结束
