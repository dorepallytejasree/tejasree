#!/bin/bash

#Commands will be executed only if root privilege is given

if [[ $EUID -ne 0 ]]; then
	echo "You need to be a root user in order to run the script"
	exit 1
fi
output_file="/home/ishita/isba/result/maintenance.sh"

#updating package repositories ad upgrade system

echo "Updating package repositories......"
apt update -y

echo "Upgrading system packages....."
apt upgrade -y

#To clean up package cache
echo "Cleaning up package cache......"
apt autoclean -y

#To clear temporary files
rm -rf /tmp/*

#Reboot the system
echo "Rebooting the system...."
#reboot

echo "Maintenance successful" >> "$output_file"
