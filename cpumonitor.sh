CPU_WARNING_THRESHOLD=0.8
MEMORY_AVAILABLE_WARNING_THRESHOLD_KB=1000000
SLACK_WEBHOOK_URL=secret
LOG_FOLDER=/var/log/cpumonitor
DELETION_DAYS=30

cpu_usage=$(awk '/^cpu / {for(ncol=2; ncol<=NF; ncol++) total+=$ncol; print 1-$5/total}' /proc/stat)
cpu_usage_descr=$(echo $cpu_usage | awk '{if ($1 < '$CPU_WARNING_THRESHOLD') print "LOW"; else print "HIGH"}')
if [ $cpu_usage_descr != "LOW" ]; then
	curl -X POST -H 'Content-type: application/json' --data '{"text":"CPU WARNING: CPU usage is '$cpu_usage_descr' with a value of '$cpu_usage' out of 1."}' $SLACK_WEBHOOK_URL
fi

memory_available_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
memory_available_kb_descr=$(echo $memory_available_kb | awk '{if ($1 < '$MEMORY_AVAILABLE_WARNING_THRESHOLD_KB') print "LOW"; else print "HIGH"}')
if [ $memory_available_kb_descr != "HIGH" ]; then
	curl -X POST -H 'Content-type: application/json' --data '{"text":"MEMORY WARNING: available memory is '$memory_available_kb_descr' with a value of '$memory_available_kb' kB."}' $SLACK_WEBHOOK_URL
fi

new_filename=$(date --iso-8601='seconds').log
mkdir -p $LOG_FOLDER
top -b -n 3 -o %CPU | awk '/^top - / {ntops++} ntops==3 {print}' > $LOG_FOLDER/$new_filename
	# first iteration is inaccurate
find $LOG_FOLDER -name '*.log' -type f -mtime +$DELETION_DAYS -exec rm -f {} \;
