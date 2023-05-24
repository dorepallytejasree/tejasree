#!/bin/bash

#check for root user privileges
if [[ $EUID -ne 0 ]]; then
	echo "Be a root user in order to run the script"
	exit 1
fi

# T1: System log files
log_file="/var/log/auth.log"
output_file="/home/ishita/isba/result/successful_login_attempts.txt"
     #search pattern
search_pattern="Accepted Password"

echo "Checking for successful login attempts....."

login_attempts=$(grep "$search_pattern" "$log_file")

if [[ -n $login_attempts ]]; then
	echo "Successful login attempts found:"
	echo "$login_attempts"
	echo "$login_attempts" >> "$output_file"			#Save login attempts to file
	echo "Successful login attempts saved to $output_file"
else
	echo "No succcessful login attempts"
fi

# T2: Unnecessary services
# Check for unnecessary daemons and services
echo "Checking for unnecessary daemons and services..."
output_file="/home/ishita/isba/result/unnecessary_service.sh"
> "$output_file"


# List all enabled services
enabled_services=$(sudo systemctl list-unit-files --type=service --state=enabled | awk '{print $1}')

# Array of unnecessary services
unnecessary_services=("avahi-daemon.service" "bluetooth.service" "nfs-common.service")

# Iterate through enabled services and check if they are unnecessary
for service in $enabled_services; do
    if [[ " ${unnecessary_services[@]} " =~ " $service " ]]; then
        echo "Service $service is unnecessary" >> "$output_file"
    fi
done

echo "Done"

# T3: Check for open ports using netstat
output_file="/home/ishita/isba/result/open_ports.txt"
> "$output_file"

echo "Checking for open ports"
netstat -aon >> "$output_file"



# T4: Unauthorized setuid and setgid
echo "Checking for unauthorized setuid files..."

output_file="/home/ishita/isba/result/unauthorized_uid_gid.txt"

> "$output_file"

# Find setuid and setgid files
setuid_files=$(find / -perm /4000 -type f 2>/dev/null)
setgid_files=$(find / -perm /2000 -type f 2>/dev/null)

# Array of authorized setuid and setgid files
authorized_files=(
    "/bin/ping"     # Example authorized setuid file
    "/usr/bin/passwd"   # Example authorized setuid file
) 
# Check for unauthorized setuid files
echo "Unauthorized setuid files:" >> "$output_file"
for file in $setuid_files; do
    if [[ ! " ${authorized_files[@]} " =~ " $file " ]]; then
        echo "$file" >> "$output_file"
    fi
done

echo "Checking for unauthorized setgid files..."

# Check for unauthorized setgid files
echo "Unauthorized setgid files:" >> "$output_file"
for file in $setgid_files; do
    if [[ ! " ${authorized_files[@]} " =~ " $file " ]]; then
        echo "$file" >> "$output_file"
    fi
done

echo "Done"


# T5: Password Policy
output_file="/home/ishita/isba/result/password_policy.txt"

> "$output_file"

# Check for password aging configuration
echo "Checking for password aging configuration..."
passwd_config_file="/etc/login.defs"
passwd_max_days=$(grep "^PASS_MAX_DAYS" $passwd_config_file | awk '{print $2}')
passwd_min_days=$(grep "^PASS_MIN_DAYS" $passwd_config_file | awk '{print $2}')
passwd_warn_age=$(grep "^PASS_WARN_AGE" $passwd_config_file | awk '{print $2}')
echo "Password aging configuration:" >> "$output_file"
echo "PASS_MAX_DAYS: $passwd_max_days" >> "$output_file"
echo "PASS_MIN_DAYS: $passwd_min_days" >> "$output_file"
echo "PASS_WARN_AGE: $passwd_warn_age" >> "$output_file"

echo "Done"
