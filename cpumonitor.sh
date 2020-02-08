CPU_WARNING_THRESHOLD=0.8
SLACK_WEBHOOK_URL=secret
LOG_FOLDER=/var/log/cpumonitor
DELETION_DAYS=30

cpu_usage=$(awk '/^cpu / {for(ncol=2; ncol<=NF; ncol++) total+=$ncol; print 1-$5/total}' /proc/stat)
cpu_usage_descr=$(echo $cpu_usage | awk '{if ($1 < '$CPU_WARNING_THRESHOLD') print "LOW"; else print "HIGH"}')
if [ $cpu_usage_descr != "LOW" ]; then
	curl -X POST -H 'Content-type: application/json' --data '{"text":"CPU WARNING: CPU usage is '$cpu_usage_descr' with a value of '$cpu_usage' out of 1."}' $SLACK_WEBHOOK_URL
fi

new_filename=$(date --iso-8601='seconds').log
mkdir -p $LOG_FOLDER
top -b -n 3 -o %CPU | awk '/^top - / {ntops++} ntops==3 {print}' > $LOG_FOLDER/$new_filename
	# first iteration is inaccurate
find $LOG_FOLDER -name '*.log' -type f -mtime +$DELETION_DAYS -exec rm -f {} \;
