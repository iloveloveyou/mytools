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
CONNARG="-h$DBIP -u$DBUSER -p$DBPASS -P$DBPORT "
#测试模式：10个仓库
WIREHOUSE=10
DBNAME="tpcc${WIREHOUSE}"
#数据预热时间：120秒
WARMUP=120
#执行测试时长：1小时
DURING=3600
#测试模式
MODE="percona55_innodb_buf26G_1bp_1000dw_xfs_deadline_6disk_raid10"

mysql $CONNARG -e "drop database $DBNAME"
mysqladmin $CONNARG create $DBNAME
mysql $CONNARG -f $DBNAME <$DIR/create_table.sql
mysql $CONNARG -f $DBNAME <$DIR/add_fkey_idx.sql
LOAD="$DIR/tpcc_load $DBIP:$DBPORT $DBNAME $DBUSER $DBPASS $WIREHOUSE"
echo $LOAD
$LOAD

##初始化测试环境
#if [ -z "`mysqlshow -h$DBIP -u$DBUSER -p$DBPASS|grep -v grep|grep \"$DBNAME\"`" ] ; then
# #mysql -h$DBIP -u$DBUSER -p$DBPASS -f $DBNAME  /proc/sys/vm/drop_caches; /etc/init.d/mysql start; sleep 60
#
##开始执行tpcc测试
#./tpcc_start -h $DBIP -d $DBNAME -u $DBUSER -p "${DBPASS}" -w $WIREHOUSE -c $THREADS -r $WARMUP -l $DURING -f ./logs/tpcc_${MODE}_${NOW}_${THREADS}_THREADS_${CYCLE}.res >> ./logs/tpcc_runlog_${MODE}_${NOW}_${THREADS}_THREADS_${CYCLE} 2>&1
#done
#
#CYCLE=`expr $CYCLE + 1`
#done
