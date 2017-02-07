for pid in `ls -l /proc | grep ^d | awk '{ print $9 }'| grep -v [^0-9]`
do
	if [ $pid -eq 1 ];then continue;fi
	grep -q "Swap"  /proc/$pid/smaps 2>/dev/null
	if [ $? -eq 0 ];then
		swap=$(grep Swap /proc/$pid/smaps | gawk '{ sum+=$2;} END{ print sum }')
		echo $swap
		proc_name=$(ps aux | grep -w "$pid" | grep -v grep | awk '{ for(i=11;i<=NF;i++){ printf("%s ",$i);}}')
		echo $proc_name
		if [ $swap -gt 0 ];then
			echo -e "${pid}\t${swap}\t${proc_name}}"
		fi
	fi
done |sort -k2 -n | awk -F'\t' '{
	pid[NR]=$1;
	size[NR]=$2;
	name[NR]=$3;
}
END{
	for(id=1;id<=length(pid);id++)
	{
		if(size[id]<1024)
			1;
		else if(size[id]<1048576)
			#printf("%-10s\t%15.2fMB\n",pid[id],size[id]/1024);
			printf("%-10s\t%15.2fMB\n",pid[id],size[id]/1024);
		else 
			printf("%s-10\t%15.2fGB\n",pid[id],size[id]/1024/1024);
	}
}'
