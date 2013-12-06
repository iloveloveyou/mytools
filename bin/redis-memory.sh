while true;do
	echo "==================================";
	ps aux|grep redis-rdb-bgsave|grep -v grep
	redis-cli -p 6370 info|grep -e used -e role;
	#echo "---------------------------------";
	#redis-cli -p 6371 info|grep -e used -e role;
	sleep 5;
done

