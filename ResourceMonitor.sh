#!/bin/bash
threshold_memory=90
threshold_cpu=90
threshold_disk=90

# Check memory usage
memory_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
if (( $(echo "$memory_usage > $threshold_memory" | bc -l) )); then
  echo "Memory usage exceeded the threshold: $memory_usage%"
  # Add notification code or other actions
else
  echo "Memory usage is within limits: $memory_usage%"
fi

# Check CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
if (( $(echo "$cpu_usage > $threshold_cpu" | bc -l) )); then
  echo "CPU usage exceeded the threshold: $cpu_usage%"
  # Add notification code or other actions
else
  echo "CPU usage is within limits: $cpu_usage%"
fi

# Check disk usage
disk_usage=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
if (( $disk_usage > $threshold_disk )); then
  echo "Disk usage exceeded the threshold: $disk_usage%"
  # Add notification code or other actions
else
  echo "Disk usage is within limits: $disk_usage%"
fi
