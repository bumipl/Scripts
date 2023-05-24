#!/bin/bash
threshold_memory=90
threshold_cpu=90
threshold_disk=90

# Variable to store the output
email_body=""

# Check memory usage
memory_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
if (( $(echo "$memory_usage > $threshold_memory" | bc -l) )); then
  email_body+="Memory usage exceeded the threshold: $memory_usage%\n"
else
  email_body+="Memory usage is within limits: $memory_usage%\n"
fi

# Check CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
if (( $(echo "$cpu_usage > $threshold_cpu" | bc -l) )); then
  email_body+="CPU usage exceeded the threshold: $cpu_usage%\n"
else
  email_body+="CPU usage is within limits: $cpu_usage%\n"
fi

# Check disk usage
disk_usage=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
if (( $disk_usage > $threshold_disk )); then
  email_body+="Disk usage exceeded the threshold: $disk_usage%\n"
else
  email_body+="Disk usage is within limits: $disk_usage%\n"
fi

#Check Disk usage space
disk_usage_table=$(df -h / /data1 /data2)
  email_body+="$disk_usage_table\n"

# Send email notification
if [ -n "$email_body" ]; then
  echo "Sending email notification..."
  echo -e "$email_body" | mail -s "System Monitoring Report" szala2002.pl@gmail.com
fi
