#!/bin/bash
# Copyright (c) 1986-2024 mashiahd
# Author: David Netanel Mashiah (mashiahd)
# License: GNU General Public License v3.0
# https://github.com/mashiahd/1minute_waf/LICENSE

set -e  # Exit immediately if a command exits with a non-zero status

current_dir=$(pwd)
log_file="$current_dir/1minwaf_install.log"

echo -e "\033[1;34m[i] Downloading utils file\033[0m"

# Try to source the script using curl if available
if command -v curl &> /dev/null; then
    if ! source <(curl -s https://raw.githubusercontent.com/mashiahd/1minute_waf/main/misc/utils.func); then
        echo -e "\033[0;33m[!] Failed to download utils.func using curl\033[0m"
        curl_successful=false
    else
        curl_successful=true
    fi
else
    echo -e "\033[0;33m[!] curl is not installed\033[0m"
    curl_successful=false
fi

# If curl attempt failed or curl is not available, try using wget
if [ "$curl_successful" != true ]; then
    echo -e "\033[1;34m[i] Downloading utils.func file using wget\033[0m"
    wget -q -O utils.func https://raw.githubusercontent.com/mashiahd/1minute_waf/main/misc/utils.func

    # Source the downloaded script
    if [ -f utils.func ]; then
        source utils.func
        echo -e "\033[1;34m[i] utils.func file downloaded successfully\033[0m"
    else
        echo -e "\033[1;31m[X] Failed to download utils.func file\033[0m"
        exit 1
    fi
fi
exit 1

# Display the banner
clear
display_banner

# Function to print help message
print_help() {
	echo "Usage: $0 [options]"
	echo "Options:"
	echo -e "  -auto_restart <${GREEN}yes${NC}|${RED}no${NC}>     Auto services restart (default: ${GREEN}yes${NC})"
	echo -e "  -remove_nginx <${GREEN}yes${NC}|${RED}no${NC}>     Remove prior Nginx installation (default: ${GREEN}yes${NC})"
	echo -e "  -nginx_ver ${WHITE}<version>${NC}       Nginx version to install (default: ${WHITE}1.25.2${NC})"
	echo -e "  -modsec_ver ${WHITE}<version>${NC}      ModSecurity version to install (default: ${WHITE}v3.0.8${NC})"
	echo -e "  -h, -?, -help              Display this help message"
}

# Default values
default_auto_restart="yes"
default_remove_nginx="yes"
default_nginx_ver="1.25.2"
default_modsec_ver="v3.0.8"

# Initialize variables with default values
auto_restart="$default_auto_restart"
remove_nginx="$default_remove_nginx"
nginx_ver="$default_nginx_ver"
modsec_ver="$default_modsec_ver"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -auto_restart) auto_restart="$2"; shift ;;
        -remove_nginx) remove_nginx="$2"; shift ;;
        -nginx_ver) nginx_ver="$2"; shift ;;
        -modsec_ver) modsec_ver="v$2"; shift ;;
        -h|-?|--help) print_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; print_help; exit 1 ;;
    esac
    shift
done

if [ $# -eq 0 ]; then
    # Print default values
    echo -e "${GREY}Default values:\n****************************${NC}"
    echo -e "${GREY}Auto Restart: ${NC}${BLUE}$auto_restart${NC}"
    echo -e "${GREY}Remove Nginx: ${NC}${BLUE}$remove_nginx${NC}"
    echo -e "${GREY}Nginx Version: ${NC}${BLUE}$nginx_ver${NC}"
    echo -e "${GREY}ModSecurity Version: ${NC}${BLUE}$modsec_ver${NC}${GREY}\n****************************${NC}"

    # Confirm with user
    while true; do
		log_info "Script Supports Arguments"
        read -p "Are you sure you want to continue with these default values? (y/n): " confirm
        case $confirm in
            [Yy]* ) break;;
            [Nn]* ) print_help; exit 0;;
            * ) echo "Please answer y or n.";;
        esac
    done
fi

# Lists of supported versions
available_nginx_versions=("1.25.2" "1.25.1" "1.24.0" "1.23.3")
available_modsec_versions=("v3.0.7" "v3.0.8" "v3.0.9" "v3.0.10")

# Validate versions
if [[ ! " ${available_nginx_versions[@]} " =~ " ${nginx_ver} " ]]; then
	log_fail "Invalid Nginx version: $nginx_ver. Supported versions: ${available_nginx_versions[*]}"
	exit 1
fi

if [[ ! " ${available_modsec_versions[@]} " =~ " ${modsec_ver} " ]]; then
	log_fail "Invalid ModSecurity version: $modsec_ver. Supported versions: ${available_modsec_versions[*]}"
	exit 1
fi

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
	log_fail "This script must be run as root"
	exit 1
else
	log_info "Script is running as root"
	log_info "Execution Started..."
fi

# Update package list
log_info "Updating Packages Information"
update_output=$( { apt update 2>&1; } )
if echo "$update_output" | grep -q "All package infos/lists are up to date."; then
	log_done "All packages are up to date"
elif echo "$update_output" | grep -q "0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded."; then
	log_done "No package infos/lists updates available"
else
	echo "$update_output" >> "$log_file"
	if [ $? -ne 0 ]; then
		log_fail "Failed to update package infos/lists, Exiting..."
		exit 1
	fi
	log_done "Package infos/lists update completed"
fi

# Install dependencies
if [ "$auto_restart" == "yes" ]; then
	log_info "Installing Dependencies - Services Will Be Restart Automatically"
	if ! DEBIAN_FRONTEND=noninteractive apt install -qq build-essential g++ libpcre2-dev flex bison curl wget apache2-dev doxygen libyajl-dev ssdeep liblua5.2-dev libgeoip-dev libtool dh-autoreconf libcurl4-gnutls-dev libxml2 libpcre3-dev libxml2-dev git liblmdb-dev libpkgconf3 lmdb-doc pkgconf zlib1g-dev libssl-dev -y > "$log_file" 2>&1; then
		log_fail "Failed to install dependencies, Exiting..."
		exit 1
	fi
else
	log_info "Installing Dependencies - Service Restart Will Be Prompted"
	if ! apt install -qq build-essential g++ libpcre2-dev flex bison curl wget apache2-dev doxygen libyajl-dev ssdeep liblua5.2-dev libgeoip-dev libtool dh-autoreconf libcurl4-gnutls-dev libxml2 libpcre3-dev libxml2-dev git liblmdb-dev libpkgconf3 lmdb-doc pkgconf zlib1g-dev libssl-dev -y; then
		log_fail "Failed to install dependencies, Exiting..."
		exit 1
	fi
fi
log_done "Installing Dependencies Done."

# Check for prior Nginx installation
log_info "Checking For Prior Nginx Installation"
if systemctl stop nginx 2>&1 | grep -q "nginx.service not loaded"; then
	log_done "No Previous Nginx Installation Found"
else
	if systemctl status nginx 2>&1 | grep -q "Active:"; then
		if [ "$remove_nginx" == "no" ]; then
			log_fail "Previous Nginx Installation Found and Running - Exiting..."
			exit 1
		elif [ "$remove_nginx" == "yes" ]; then
			log_warning "Previous Nginx Installation Found but Not Running. Removing..."
			# Nginx should be already stopped in existence check
			if ! apt remove --purge nginx -y >> "$log_file" 2>&1; then
				log_fail "Failed to remove previous Nginx installation, Exiting..."
				exit 1
			fi
			log_done "Previous Nginx Installation Removed"
		else
			log_fail "Previous Nginx Installation Found - Not Supported - Exiting..."
			exit 1
		fi
	else
		log_fail "Previous Nginx Installation Found - Not Supported - Exiting..."
		exit 1
	fi
fi

# Installing ModSec
log_info "Downloading ModSecurity Version - $modsec_ver"
modsec_filename="modsecurity-$modsec_ver.tar.gz"

output=$(wget "https://github.com/SpiderLabs/ModSecurity/releases/download/$modsec_ver/$modsec_filename" 2>&1 | tee -a "$log_file")
if [[ $output == *"200 OK"* ]]; then
	log_done "Modsec $modsec_ver Downloaded"
	tar -xvzf "$modsec_filename" > /dev/null 2>&1 || { log_fail "Error extracting the file."; exit 1; }
	log_done "ModSec Files Extracted"
else
	log_fail "Modsec $modsec_ver Couldn't Be Downloaded, Exiting..."
	exit 1
fi

cd "modsecurity-$modsec_ver" >> "$log_file" 2>&1 || { log_fail "Error entering the directory."; exit 1; }
log_info "Starting build.sh"
./build.sh >> "$log_file" 2>&1 && log_done "build Done" || { log_fail "Error during build."; exit 1; }

log_info "Starting configure"
./configure >> "$log_file" 2>&1 && log_done "configure Done" || { log_fail "Error during configure."; exit 1; }

log_info "Making ModSec"
make >> "$log_file" 2>&1 && log_done "ModSec Make Done" || { log_fail "Error during make."; exit 1; }

log_info "Starts ModSec Install"
make install >> "$log_file" 2>&1 && log_done "ModSec make install Done" || { log_fail "Error during make install."; exit 1; }
log_done "Finished ModSec Install"

##########################################
#### Install Nginx w\ModSec 3 Support ####
##########################################
log_info "Starting Nginx Install"

cd ~ || { log_done "Error changing directory to home."; exit 1; }

output=$(git clone https://github.com/SpiderLabs/ModSecurity-nginx.git 2>&1 | tee -a "$log_file")
if [[ $output == *"Cloning into"* ]]; then
	log_done "Cloning the ModSecurity-nginx connector via git"
else
	log_fail "Error cloning the repository, Exiting..."
	exit 1
fi

log_done "ModSecurity-nginx git cloned"

log_info "Downloading Nginx Source File $nginx_ver"
nginx_filename="nginx-$nginx_ver.tar.gz"

if wget "https://nginx.org/download/$nginx_filename" -O "$nginx_filename" >> "$log_file" 2>&1; then
	log_done "Nginx File Found - Downloading"
	if tar xzf "$nginx_filename" > /dev/null 2>&1; then
		log_done "Nginx Downloaded"
		log_done "Nginx Files Extracted"
	else
		log_fail "Error extracting the file."
		exit 1
	fi
else
	log_fail "Nginx File Not Found, Exiting..."
	exit 1
fi

# Create a user for Nginx
if useradd -r -M -s /sbin/nologin -d /usr/local/nginx nginx >> "$log_file" 2>&1; then
	log_done "Created user for Nginx"
else
	log_done "Failed to create user for Nginx"
	exit 1
fi

# Configure the Nginx source
log_done "Nginx Configuration Started"
cd "nginx-$nginx_ver" > /dev/null 2>&1 || { log_done "Error changing to nginx-$nginx_ver directory."; exit 1; }

# Adjusted the directory for dynamic module to avoid hardcoding root's home directory
./configure --user=nginx --group=nginx --with-pcre-jit --with-debug --with-compat --with-http_v2_module --with-http_ssl_module --with-http_realip_module --add-dynamic-module=$(pwd)/../ModSecurity-nginx --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log >> "$log_file" 2>&1
if [ $? -ne 0 ]; then
	log_done "Nginx Configuration Failed"
	exit 1
fi

log_done "Nginx Configuration Finished"

# Install Nginx
log_info "Installing Nginx"
make > /dev/null 2>&1 || { log_fail "make failed."; exit 1; }
make modules > /dev/null 2>&1 || { log_fail "make modules failed."; exit 1; }
make install > /dev/null 2>&1 || { log_fail "make install failed."; exit 1; }

# Symbolic link of Nginx
if ln -s /usr/local/nginx/sbin/nginx /usr/local/sbin/ > /dev/null 2>&1; then
	log_done "nginx symbolic link Was Created"
else
	log_done "Failed to create nginx symbolic link."
	exit 1
fi

# Symbolic Nginx folder link
if ln -s "/usr/local/nginx/" "/etc/nginx" > /dev/null 2>&1; then
	log_done "nginx symbolic folder link Was Created"
else
	log_done "Failed to create nginx folder symbolic link."
	exit 1
fi

##########################################
#### Configure Nginx with ModSecurity ####
##########################################
log_info "Starting Nginx ModSecurity Configuration"

# 1. Copy the sample configuration files
# Creating necessary directories
if mkdir -p "/usr/local/nginx/sites-available" > /dev/null 2>&1; then
	log_done "Created sites-available Folder"
else
	log_fail "Failed to create sites-available folder. Exiting..."
	exit 1
fi

if mkdir -p "/usr/local/nginx/sites-enabled" > /dev/null 2>&1; then
	log_done "Created sites-enabled Folder"
else
	log_fail "Failed to create sites-enabled folder. Exiting..."
	exit 1
fi

# Copying configuration files
if cp "$current_dir/modsecurity-$modsec_ver/modsecurity.conf-recommended" "/usr/local/nginx/conf/modsecurity.conf" > /dev/null 2>&1; then
	log_done "Copied modsecurity.conf-recommended to modsecurity.conf"
else
	log_fail "Failed to copy modsecurity.conf-recommended. Exiting..."
	exit 1
fi

if cp "$current_dir/modsecurity-$modsec_ver/unicode.mapping" "/usr/local/nginx/conf/" > /dev/null 2>&1; then
	log_done "Copied unicode.mapping to nginx conf directory"
else
	log_fail "Failed to copy unicode.mapping. Exiting..."
	exit 1
fi

# 2. Backup the Nginx configuration
if cp "/usr/local/nginx/conf/nginx.conf" "/usr/local/nginx/conf/nginx.conf.bak" > /dev/null 2>&1; then
	log_done "Backed up nginx.conf to nginx.conf.bak"
else
	log_fail "Failed to back up nginx.conf. Exiting..."
	exit 1
fi

# 3. Edit nginx configuration
> /usr/local/nginx/conf/nginx.conf > /dev/null 2>&1
cat <<EOF >> /usr/local/nginx/conf/nginx.conf
load_module modules/ngx_http_modsecurity_module.so;
user nginx;
worker_processes 1;
pid        /run/nginx.pid;
events {
	worker_connections  1024;
}
http {
	tcp_nopush on;
	types_hash_max_size 2048;

	include       mime.types;
	default_type  application/octet-stream;

	sendfile        on;
	keepalive_timeout  65;
	gzip on;

	include /usr/local/nginx/conf.d/*.conf;
	include /usr/local/nginx/sites-enabled/*;

	server {
		listen       8080;
		server_name  localhost;
		modsecurity  on;
		modsecurity_rules_file  /usr/local/nginx/conf/modsecurity.conf;
		access_log /var/log/nginx/test_access_example.log;
		error_log /var/log/nginx/test_error_example.log;
		location / {
			root   html;
			index  index.html index.htm;
		}
		error_page   500 502 503 504  /50x.html;
		location = /50x.html {
			root   html;
		}
	}
}
EOF
log_done "Created nginx.conf for ModSecurity"

# 4. Enable the ModSecurity
sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /usr/local/nginx/conf/modsecurity.conf > /dev/null 2>&1
log_done "ModSecurity Enabled"

###########################################
#### Install ModSecurity Core Rule Set ####
###########################################

# 1. Download the OWASP rule set
log_info "Downloading OWASP rule set"
cd > /dev/null 2>&1
output=$(git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/local/nginx/conf/owasp-crs 2>&1 | tee -a "$log_file")
if [[ $output == *"Cloning into"* ]]; then
	log_done "OWASP rule set cloned"
else
	log_done "Error cloning OWASP rule set, Exiting..."
	exit 1
fi

# 2. rename crs-setup.conf.example to crs-setup.conf
cp /usr/local/nginx/conf/owasp-crs/crs-setup.conf{.example,} > /dev/null 2>&1
log_info "Renamed crs-setup.conf.example to crs-setup.conf"

# 3. Define the rules
echo "Include owasp-crs/crs-setup.conf" >> "/usr/local/nginx/conf/modsecurity.conf"
if grep -q "Include owasp-crs/crs-setup.conf" "/usr/local/nginx/conf/modsecurity.conf"; then
	log_done "Successfully appended crs-setup.conf to ModSec configuration"
else
	log_fail "Failed to append crs-setup.conf to ModSec configuration"
fi

echo "Include owasp-crs/rules/*.conf" >> "/usr/local/nginx/conf/modsecurity.conf"
if grep -q "Include owasp-crs/rules/\*.conf" "/usr/local/nginx/conf/modsecurity.conf"; then
	log_done "Successfully appended rules/*.conf to ModSec configuration"
else
	log_fail "Failed to append rules/*.conf to ModSec configuration"
fi

# 4. Nginx configuration testing
log_info "Nginx configuration testing"

output=$(/usr/local/nginx/sbin/nginx -t 2>&1 | tee -a "$log_file")
if [[ $output == *"syntax is ok" || $output == *"test is successful" ]]; then
	log_done "Nginx Conf Is Ok!"
else
	log_done "Nginx Conf Is Broken!"
	exit 1
fi

#############################################
####### Create & Manage Nginx Service #######
#############################################

# 1. Create Nginx systemd service file
cat <<EOF >> /etc/systemd/system/nginx.service
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/local/nginx/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/local/nginx/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
log_done "Created nginx.service file"

# 2. Start and Enable Nginx 
# Reload systemd daemon
if systemctl daemon-reload > /dev/null 2>&1; then
	log_done "Daemon reloaded"
else
	log_fail "Failed to reload daemon. Exiting..."
	exit 1
fi

# Start nginx service
if systemctl start nginx > /dev/null 2>&1; then
	log_done "Nginx service started"
else
	log_fail "Failed to start Nginx service. Exiting..."
	exit 1
fi

# Enable nginx service to run at startup
if systemctl enable nginx > /dev/null 2>&1; then
	log_done "Nginx set to run at startup"
else
	log_fail "Failed to enable Nginx to run at startup. Exiting..."
	exit 1
fi

output=$(systemctl status nginx 2>&1)
if [[ $output == *"running"* ]]; then
	log_done "Nginx Is Running!"
else
	log_done "Nginx Failed!"
	exit 1
fi

##############################################
########### Test ModSecurity Block ###########
##############################################

# 1. Test Block
output=$(curl -s localhost:8080?doc=/bin/ls 2>&1)
if [[ $output == *"Forbidden"* ]]; then
	log_done "Blocking Test Succeed"
else
	log_fail "Blocking Test Failed"
	exit 1
fi

# 2. Show Log Data
if grep -q "Remote Command Execution: Unix Shell Code Found" /var/log/modsec_audit.log; then
	log_done "Block Log Was Found in modsec_audit.log"
else
	log_fail "Block Log Was NOT Found in modsec_audit.log"
fi

log_done "Script execution completed"