#!/bin/bash

# Healthcheck thresholds
cpu_threshold_p1=5  # High load (5 minutes)
cpu_threshold_p2=3  # Moderate load (5 minutes)
memory_threshold_p1=95
memory_threshold_p2=90
disk_threshold_p1=95
disk_threshold_p2=85

# Email configuration
email_recipient="$1"
email_subject_p1="P1 - Raspberry Pi Monitoring Alert"
email_subject_p2="P2 - Raspberry Pi Monitoring Alert"
email_subject_report="Raspberry Pi Monitoring Report"
email_message=""

# Log file configuration
log_file="/var/log/raspi_monitoring.log"

# Ensure system packages is installed
check_packages() {
   if ! dpkg -l | grep -wq bc ; then
	echo "bc package is not installed. Installing..."
	sudo apt install bc -y
   fi
}

# Function to open the log file with hashes
open_log() {
    echo "#########################" | tee -a "$log_file"
}

# Function to close the log file with hashes
close_log() {
    echo "#########################" | tee -a "$log_file"
}

# Function to log messages (without hashes)
log_message() {
    echo "$1" | tee -a "$log_file"
}

# Function to append email message
append_message() {
    email_message+="\n$1"
    log_message "$1"
}

# Function to send an email
send_email() {
    echo -e "$email_message" | mail -s "$email_subject" "$email_recipient"
}

# Function to check uptime
check_uptime() {
    local uptime_start=$(uptime -s)
    append_message "Server uptime since: $uptime_start"
    if [[ -z $email_subject ]]; then
        email_subject="$email_subject_report"
    fi
}

# Function to check CPU load
check_cpu_usage() {
    local cpu_load=$(awk '{print $2}' /proc/loadavg)

    if (( $(echo "$cpu_load >= $cpu_threshold_p1" | bc -l) )); then
        email_subject="$email_subject_p1"
        append_message "CPU load (5m average) is above $cpu_threshold_p1: $cpu_load"
    elif (( $(echo "$cpu_load >= $cpu_threshold_p2" | bc -l) )); then
        email_subject="$email_subject_p2"
        append_message "CPU load (5m average) is above $cpu_threshold_p2: $cpu_load"
    else
        log_message "CPU load (5m average): $cpu_load"
    fi
}

# Function to check memory usage
check_memory_usage() {
    local memory_usage=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100.0}')
    local swap_usage=$(free | awk '/Swap:/ {printf "%.2f", $3/$2 * 100.0}')

    if (( $(echo "$memory_usage >= $memory_threshold_p1" | bc -l) )) || (( $(echo "$swap_usage > 80" | bc -l) )); then
        email_subject="$email_subject_p1"
        append_message "Memory usage is above $memory_threshold_p1% or swapping is enabled. Mem: $memory_usage%, Swap: $swap_usage%"
    elif (( $(echo "$memory_usage >= $memory_threshold_p2" | bc -l) )); then
        email_subject="$email_subject_p2"
        append_message "Memory usage is above $memory_threshold_p2%. Mem: $memory_usage%"
    else
        log_message "Memory usage: $memory_usage%, Swap usage: $swap_usage%"
    fi
}


# Function to check disk usage
check_disk_usage() {
    local disk_usage=$(df -h --output=pcent / | awk 'NR==2 {gsub(/%/, ""); print $1}')
    local export_usage=$(du -sh /export 2>/dev/null | awk '{print $1}')

    if (( $(echo "$disk_usage >= $disk_threshold_p1" | bc -l) )); then
        email_subject="$email_subject_p1"
        append_message "Disk usage is above $disk_threshold_p1%. /: $disk_usage%, /export: $export_usage%"
    elif (( $(echo "$disk_usage >= $disk_threshold_p2" | bc -l) )); then
        email_subject="$email_subject_p2"
        append_message "Disk usage is above $disk_threshold_p2%. /: $disk_usage%, /export: $export_usage%"
    else
        log_message "Disk usage: Root: $disk_usage%, /export: $export_usage"
    fi
}

# Function to check journalctl for errors
check_journalctl_errors() {
    local errors=$(journalctl -p err -b | grep -i error)
    if [[ -n $errors ]]; then
        email_subject="$email_subject_p1"
        append_message "Errors detected in journalctl logs: $errors"
    else
        log_message "No critical errors in journalctl logs."
    fi
}

# Function to check system temperature
check_temperature() {
    local temperature=$(vcgencmd measure_temp | grep -oE '[0-9]+\.[0-9]+')
    if (( $(echo "$temperature > 70.0" | bc -l) )); then
        email_subject="$email_subject_p2"
        append_message "High system temperature detected: ${temperature}C"
    elif (( $(echo "$temperature > 75.0" | bc -l) )); then
        email_subject="$email_subject_p1"
        append_message "High system temperature detected: ${temperature}C"     
    else
        append_message "System temperature: ${temperature}C"
    fi
}

# Function to check Docker container status
check_docker_containers() {
    local unhealthy_containers=$(docker ps --filter "health=unhealthy" --format '{{.Names}}: {{.Status}}')
    local exited_containers=$(docker ps -a --filter "status=exited" --format '{{.Names}}: {{.Status}}')

    if [[ -n $unhealthy_containers ]]; then
        email_subject="$email_subject_p1"
        append_message "Unhealthy Docker containers detected: $unhealthy_containers"
    fi

    if [[ -n $exited_containers ]]; then
        email_subject="$email_subject_p2"
        append_message "Exited Docker containers detected: $exited_containers"
    fi

    log_message "Docker container status checked."
}

# Function to check if necessary packages are installed
check_packages

# Function to perform all checks
perform_checks() {
    check_uptime
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_journalctl_errors
    check_temperature
    check_docker_containers
}

# Function to send the email if there are alerts or errors
send_alert_email() {
    if [[ -n $email_message ]]; then
        send_email
    fi
}

# Open the log with hashes at the start
open_log

# Perform checks
perform_checks

# Close the log with hashes at the end
close_log

# Send alert email if needed
send_alert_email

exit 0
