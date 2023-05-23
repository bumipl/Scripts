#!/bin/bash
threshold=90
memory_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')

if (( $(echo "$memory_usage > $threshold" | bc -l) )); then
  echo "Memory usage has exceeded the threshold: $memory_usage%
else
  echo "Memory usage is okay: $memory_usage%"
fi
