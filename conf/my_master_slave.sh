#!/bin/sh
#修复mysql主从同步
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
LOGFILE=/data/repair_mysql_sync_`date +%F`.log
SQLCMD1="show slave status"
#查看MySQL是否启动
retval=`ps aux | grep mysqld | grep -v grep`
if [ "${retval}X" = "X" ]; then
    echo The MySQL is not running at: `date +%F" "%H-%M-%S` >> ${LOGFILE}
    exit 1
fi
#获得MySQL从端Relay binlog的路径
retval=`grep "^relay-log" /etc/my.cnf | grep -v relay-log- | grep '/'`
if [ "${retval}" = "X" ]; then
    RELAY_BINLOG_PATH=`ps aux | grep -w mysqld | grep -v grep | awk '{print $13}' | awk -F '=' '{print $2}'`
else
    RELAY_BINLOG_PATH=`dirname $(echo ${retval} | awk -F '=' '{print $2}')`
fi
#查找master.info文件，用于定位Binlog信息
MASTER_FILE=`ps aux | grep -w mysqld | grep -v grep | awk '{print $13}' | awk -F '=' '{print $2}'`/master.info
if [ ! -e ${MASTER_FILE} ]; then
   echo This Server is not MySQL Slave at: `date +%F" "%H-%M-%S` >> ${LOGFILE}
   exit 1
fi
#获得当前的同步状态
IO_STATUS=`mysql -uroot -e "${SQLCMD1}\G;" | awk '$1=="Slave_IO_Running:" {print $2}'`
SQL_STATUS=`mysql -uroot -e "${SQLCMD1}\G;" | awk '$1=="Slave_SQL_Running:" {print $2}'`
if [[ "${IO_STATUS}" = "Yes" && "${SQL_STATUS}" = "Yes" ]]; then
   echo Now, The MySQL Replication is synchronous at: `date +%F" "%H-%M-%S` >> ${LOGFILE}
   exit 0
fi
#从master.info文件中，获得MySQL主端的同步信息
REPLI_INFO=`sed '/^$/d' ${MASTER_FILE} | tail +2 | head -5`
REPLI_BINLOG_FILE=`echo ${REPLI_INFO} | awk '{print $1}'`
REPLI_IPADDR=`echo ${REPLI_INFO} | awk '{print $3}'`
REPLI_USER=`echo ${REPLI_INFO} | awk '{print $4}'`
REPLI_PWD=`echo ${REPLI_INFO} | awk '{print $5}'`
#删除无用的Relay binlog
rm -rf ${RELAY_BINLOG_PATH}/*-relay-bin.*
#直接从0位置开始同步
SQLCMD2="change master to master_host='${REPLI_IPADDR}', master_user='${REPLI_USER}', master_password='${REPLI_PWD}',"
SQLCMD2="${SQLCMD2} master_log_file='${REPLI_BINLOG_FILE}', master_log_pos=0"
mysql -uroot -e "stop slave;"
mysql -uroot -e "${SQLCMD2};"
mysql -uroot -e "start slave;"
#如果同步的过程中，出现重复记录导致同步失败，就跳过
while true
do
   sleep 2
   IO_STATUS=`mysql -uroot -e "${SQLCMD1}\G;" | awk '$1=="Slave_IO_Running:" {print $2}'`
   SQL_STATUS=`mysql -uroot -e "${SQLCMD1}\G;" | awk '$1=="Slave_SQL_Running:" {print $2}'`
   BEHIND_STATUS=`mysql -uroot -e "${SQLCMD1}\G;" | awk '$1=="Seconds_Behind_Master:" {print $2}'`
   SLAVE_BINLOG1=`mysql -uroot -e "${SQLCMD1}\G;" | awk '$1=="Master_Log_File:" {print $2}'`
   SLAVE_BINLOG2=`mysql -uroot -e "${SQLCMD1}\G;" | awk '$1=="Relay_Master_Log_File:" {print $2}'`
   #出现错误，就将错误信息记录到日志文件，并跳过错误继续同步
   if [[ "${IO_STATUS}" != "Yes" || "${SQL_STATUS}" != "Yes" ]]; then
       ERRORINFO=`mysql -uroot -e "${SQLCMD1}\G;" | awk -F ': ' '$1=="Last_Error" {print $2}'`
       echo "The MySQL synchronous error information: ${ERRORINFO}" >> ${LOGFILE}
       mysql -uroot -e "stop slave;"
       mysql -uroot -e "set GLOBAL SQL_SLAVE_SKIP_COUNTER=1;"
       mysql -uroot -e "start slave;"
       #已完成同步，就正常退出
   elif [[ "${IO_STATUS}" = "Yes" && "${SQL_STATUS}" = "Yes" && "${SLAVE_BINLOG1}" = "${SLAVE_BINLOG2}" && ${BEHIND_STATUS} -eq 0 ]]; then
      echo The MySQL synchronous is ok at: `date +%F" "%H-%M-%S` >> ${LOGFILE}
      break
 fi
done