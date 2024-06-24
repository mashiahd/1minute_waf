#!/bin/bash
# Copyright (c) 1986-2024 mashiahd
# Author: David Netanel Mashiah (mashiahd)
# License: GNU General Public License v3.0
# https://github.com/mashiahd/1minute_waf/LICENSE
source <(curl -s https://raw.githubusercontent.com/mashiahd/1minute_waf/main/misc/utils.func)

current_dir=$(pwd)
log_file="$current_dir/1minwaf_install.log"

# Display the banner
clear
display_banner

# Call function to check disk usage
check_disk_usage

# Set variables
CT_ID=$(get_next_ct_id)
PASSWORD="1minwaf"
HOSTNAME="modsec-nginx"
STORAGE="local-lvm"
TEMPLATE_FILENAME="ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
FULL_TEMPLATE="local:vztmpl/$TEMPLATE_FILENAME"
SCRIPT_URL="https://raw.githubusercontent.com/mashiahd/1minute_waf/main/platform/vm/modsec-nginx.sh"
SCRIPT_NAME="modsec-nginx.sh"

log_info "Preparing Environment..."
log_data "Next available CT ID:" "$CT_ID"
log_data "Cores:" "2"
log_data "Memory:" "2048"
log_data "Hostname:" "$HOSTNAME"
log_data "Storage:" "$STORAGE"
log_data "Template:" "$TEMPLATE_FILENAME"
log_data "Network Interface:" "eth0"
log_data "Network Bridge:" "vmbr0"
log_data "Network Firewall:" "1"
log_data "Network IP:" "DHCP"

# Check if the template exists and download it if it does not
log_info "Looking for template file..."
if ! pveam list local | grep -q "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"; then
	log_warning "Template not found, downloading..."
	pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
	if [[ $? -eq 0 ]]; then
		log_done "Template downloaded successfully"
	else
		log_fail "Failed to download template"
		exit 1
	fi
else
	log_info "Template file found"
fi

# Create the container
log_info "Creating container..."
output=$(pct create $CT_ID $FULL_TEMPLATE --hostname $HOSTNAME --storage $STORAGE --net0 name=eth0,bridge=vmbr0,firewall=1,ip=dhcp --memory 2048 --cores 2 --password $PASSWORD 2>&1)
if [[ $? -eq 0 ]]; then
	log_done "Container creation"
else
	log_fail "Container creation Failed"
	log_error "Error: $output"
	exit 1
fi

# Set the container to start at boot
output=$(pct set $CT_ID --onboot 1 2>&1)
if [[ $? -eq 0 ]]; then
	log_info "Container set to start at boot"
else
	log_warning "Error setting to start at boot"
fi

# Remove Swap Memory for high performance
output=$(pct set $CT_ID --swap 0 2>&1)
if [[ $? -eq 0 ]]; then
	log_info "Swap memory removed"
else
	log_warning "Failed to remove swap memory"
fi

# Start the container
log_info "Starting container..."
output=$(pct start $CT_ID 2>&1)
if [[ $? -eq 0 ]]; then
	sleep 10
	status=$(pct status $CT_ID | grep -oP 'status: \K\w+')
	if [[ $status == "running" ]]; then
		log_done "Container started successfully"
	else
		log_fail "Container failed to start"
		exit 1
	fi
else
	log_fail "Starting container: Failed"
	log_fail "Error: $output"
	exit 1
fi

description

output=$(pct exec $CT_ID -- hostname -I 2>&1)
if [[ $? -eq 0 && -n "$output" ]]; then
	echo -e "${BLUE}[🖧] Network Connected: ${NC}${WHITE}$output${NC}"
else
	log_fail "No Network After $RETRY_NUM Tries"
	log_error "🖧 Check Network Settings"
	exit 1
fi

# Update and upgrade the system
log_info "Updating and upgrading OS..."

output=$(pct exec $CT_ID -- apt-get update 2>&1)
if [[ $? -eq 0 ]]; then
	log_done "OS Update Done"
else
	log_fail "OS Update & Upgrade Failed"
	log_error "Error: $output"
	exit 1
fi

output=$(pct exec $CT_ID -- apt-get -y upgrade 2>&1)
if [[ $? -eq 0 ]]; then
	log_done "System Upgrade Done"
else
	log_fail "System upgrade Failed"
	log_error "Error: $output"
	exit 1
fi

output=$(pct exec $CT_ID -- apt-get install -y curl 2>&1)
if [[ $? -eq 0 ]]; then
	log_done "Curl Installed"
else
	log_fail "Curl Installation Failed"
	log_error "Error: $output"
	exit 1
fi

# Download the script inside the container
log_info "Downloading installation script from Github"
output=$(pct exec $CT_ID -- wget -O /root/$SCRIPT_NAME $SCRIPT_URL 2>&1)
if [[ $? -eq 0 ]]; then
	log_done "Installation File Downloaded"
else
	log_fail "Error downloading: $output"
	log_error "Error: $output"
	exit 1
fi

# Give execute permissions to the script
log_info "Setting execute permissions to installation script"
output=$(pct exec $CT_ID -- chmod +x /root/$SCRIPT_NAME 2>&1)
if [[ $? -eq 0 ]]; then
	log_done "Execution Permission set successfully"
else
	log_fail "Setting Execution Permission Failed"
	log_error "Error: $output"
	exit 1
fi

# Run the script as root and see the output live
log_info "Executing installation script"
if lxc-attach -n $CT_ID -- bash -c "source /etc/profile && /root/$SCRIPT_NAME"; then
	log_done "Installation Script executed successfully"
else
	log_fail "Installation Script execution Failed"
	exit 1
fi

log_done "Container $CT_ID is now a Modsec-Nginx Node."
log_data "root Password:" "$PASSWORD"
