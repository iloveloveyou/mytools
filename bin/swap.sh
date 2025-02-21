###############################################################################
# 日期 : 2011-10-31
# 作者 : xiaoxi227
# Email : xiaoxi227@163.com
# QQ : 451914397
# 版本 : 1.0
# 脚本功能 ： 列出正在占用swap的进程。
# 调用关系 ：
# 其他说明 ：
###############################################################################
echo -e "PID\t\tSwap\t\tProc_Name"
 
# 拿出/proc目录下所有以数字为名的目录（进程名是数字才是进程，其他如sys,net等存放的是其他信息）
for pid in `ls -l /proc | grep ^d | awk '{ print $9 }'| grep -v [^0-9]`
do
# 让进程释放swap的方法只有一个：就是重启该进程。或者等其自动释放。
# 如果进程会自动释放，那么我们就不会写脚本来找他了，找他都是因为他没有自动释放。
# 所以我们要列出占用swap并需要重启的进程，但是init这个进程是系统里所有进程的祖先进程
# 重启init进程意味着重启系统，这是万万不可以的，所以就不必检测他了，以免对系统造成影响。
if [ $pid -eq 1 ];then continue;fi # Do not check init process
# 判断改进程是否占用了swap
grep -q "Swap" /proc/$pid/smaps 2>/dev/null
if [ $? -eq 0 ];then	# 如果占用了swap
# 占用swap的总大小（单位：KB）
swap=$(grep Swap /proc/$pid/smaps | gawk '{ sum+=$2;} END{ print sum }')
# 进程名
proc_name=$(ps aux | grep -w "$pid" | grep -v grep | awk '{ for(i=11;i<=NF;i++){ printf("%s ",$i); }}')
if [ $swap -gt 0 ];then	# 如果占用了swap则输出其信息
echo -e "$pid\t${swap}\t$proc_name"
fi
fi
# 按占用swap的大小排序，再用awk实现单位转换。
# 如：将1024KB转换成1M。将1048576KB转换成1G，以提高可读性。
done | sort -k2 -n | gawk -F'\t' '{
pid[NR]=$1;
size[NR]=$2;
name[NR]=$3;
}
END{
for(id=1;id<=length(pid);id++)
{
    if(size[id]<1024)
          printf("%-10s\t%15sKB\t%s\n",pid[id],size[id],name[id]);
    else if(size[id]<1048576)
          printf("%-10s\t%15.2fMB\t%s\n",pid[id],size[id]/1024,name[id]);
    else
  printf("%-10s\t%15.2fGB\t%s\n",pid[id],size[id]/1048576,name[id]);
}
}'
