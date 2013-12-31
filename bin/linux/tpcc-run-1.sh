#!/bin/bash
export LD_LIBRARY_PATH=/usr/local/mysql/lib/ 
#. ~/.bash_profile >/dev/null 2>&1
DIR=$(pwd)

BASEDIR="/home/data/tpcc"
cd $BASEDIR
mkdir -p $BASEDIR/logs

#exec 3>&1 4>&2 1>> tpcc.log 2>&1

#执行tpcc测试的数据库IP
DBIP='127.0.0.1'
DBUSER='replication'
DBPASS='123456'
DBPORT='3301'
#测试模式：10个仓库
WIREHOUSE=10
DBNAME="tpcc${WIREHOUSE}"
#数据预热时间：120秒
WARMUP=120
#执行测试时长：1小时
DURING=3600
#测试模式
MODE="MySQL55_innodb_buf9G_8bp_1000dw_ext3_deadline_3disk_raid0"

#初始化测试环境

CONNARG="-h$DBIP -u$DBUSER -p$DBPASS -P$DBPORT "
#if [ -z "`mysqlshow $CONNARG|grep -v grep|grep \"$DBNAME\"`" ] ; then
#fi


CYCLE=0
TOTAL=3
NOW=`date +'%Y%m%d%H%M'`
while [ $CYCLE -lt $TOTAL ]
do

	#测试并发线程：8 ~ 256
	#for THREADS in 8 16 32 64 128 256 
	for THREADS in 48 64 128
	do
		/bin/start_mysql 1;sleep 5;
		mysql $CONNARG -e "drop database $DBNAME"
		#重启mysqld
		#/etc/init.d/mysql stop; echo 3 > /proc/sys/vm/drop_caches; /etc/init.d/mysql start; sleep 60
		/bin/stop_mysql 1;sleep 5;echo 3 > /proc/sys/vm/drop_caches;/bin/start_mysql 1;sleep 20
		mysqladmin $CONNARG create $DBNAME
		mysql $CONNARG -f $DBNAME <$DIR/create_table.sql
		#mysql $CONNARG -f $DBNAME <$DIR/add_fkey_idx.sql
		LOAD="$DIR/tpcc_load $DBIP:$DBPORT $DBNAME $DBUSER $DBPASS $WIREHOUSE";echo $LOAD;$LOAD
		#开始执行tpcc测试
		echo 'begin tpcc test'
		#tpcc_start -h server_host -P port -d database_name -u mysql_user -p mysql_password -w warehouses -c connections -r warmup_time -l running_time -i report_interval -f report_file -t trx_file
		$DIR/tpcc_start $CONNARG -d $DBNAME -w $WIREHOUSE -c $THREADS -r $WARMUP -l $DURING -f ./logs/${NOW}_tpcc_${MODE}_${THREADS}_THREADS_${CYCLE}.res >> ./logs/${NOW}_tpcc_${MODE}_${THREADS}_THREADS_${CYCLE}.log 2>&1
	done
	CYCLE=`expr $CYCLE + 1`
done
