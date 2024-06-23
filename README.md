# 1-Minute WAF Installer

This repository contains a bash script for installing Nginx with ModSecurity 3 support. The script also includes features for checking and managing previous Nginx installations, and supports automatic service restarts.

## Table of Contents

- [1-Minute WAF Installer](#1-minute-waf-installer)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Support Operating Systems](#support-operating-systems)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
    - [Host/VM](#hostvm)
    - [Proxmox VE (lxc)](#proxmox-ve-lxc)
  - [Usage](#usage)
    - [Command Line Arguments](#command-line-arguments)
    - [Default Values](#default-values)
  - [Troubleshooting](#troubleshooting)
  - [License](https://github.com/mashiahd/1minute_waf/blob/main/LICENSE)

## Features
<<<<<<< HEAD

=======
>>>>>>> 6593561a0c8db99efa4b3673d017d4dc1c00b88f
- Direct install on host or vm using vm script
- Install on Proxmox 
- Install Nginx with ModSecurity 3 support
- Automatic detection and removal of prior Nginx installations
- Customizable Nginx and ModSecurity versions
- Supports automatic service restarts
- Fall-back mechanism for downloading utility functions using `wget` if `curl` is not available

## Support Operating Systems

- A debain linux-based operating system (tested on ubuntu 22.04.01)
- A Proxmox VE 7.4-11 (Version 8 not tested yet)

## Prerequisites

- Root privileges for installation
- Network connection for downloading necessary files

## Installation

<<<<<<< HEAD
### Host/VM

Option 1:
Download and install via bash on you local machine:

```bash
sudo bash -c "$(wget -qLO - https://github.com/mashiahd/1minute_waf/blob/main/platform/vm/modsec-nginx.sh)"
```

Option 2:
git clone https://github.com/mashiahd/1minute_waf.git
cd ./1minute_waf/platform/vm
chmod +x modsec-nginx.sh
sudo ./modsec-nginx.sh [options]

### Proxmox VE (lxc)

Option 1:
Download and install via bash on lxc conatiner (Linux Container):

```bash
sudo bash -c "$(wget -qLO - https://github.com/mashiahd/1minute_waf/blob/main/platform/proxmox_ct/modsec_nginx_proxmox.sh)"
```

Option 2:
git clone https://github.com/mashiahd/1minute_waf.git
cd ./1minute_waf/platform/proxmox_ct
chmod +x modsec_nginx_proxmox.sh
sudo ./modsec_nginx_proxmox.sh [options]

## Usage
If repository cloned run the script with or without command-line arguments:

```bash
sudo ./modsec-nginx.sh [options]
```

### Command Line Arguments
`-auto_restart <yes|no>`     Auto services restart (default: yes)

`-remove_nginx <yes|no>`     Remove prior Nginx installation (default: yes)

`-nginx_ver <version>`       Nginx version to install (default: 1.25.2)

`-modsec_ver <version>`      ModSecurity version to install (default: v3.0.8)

`-h, -?, -help`              Display this help message

### Default Values
If no arguments are provided, the script will use the following default values:
- Auto services restart: `yes`
- Remove prior Nginx installation: `yes`
- Nginx version: `1.25.2`
- ModSecurity version: `v3.0.8`

Before proceeding with the installation, you will be prompted to confirm these default values.

## Troubleshooting
If you encounter any issues during the installation, check the `1minwaf_install.log` file located in the same directory for detailed logs.

Common issues:
- Ensure you have root privileges to run the script.
- Check your network connection for downloading necessary files.
=======
Download and install via bash on you local machine:

```bash
sudo bash -c "$(wget -qLO - https://api.int.mashiahs.com/downloads/automation/modsec-nginx.sh)"

## Usage
If cloned run the script with or without command-line arguments:

```bash
sudo chmod +x install_waf.sh
sudo ./modsec-nginx.sh [options]

>>>>>>> 6593561a0c8db99efa4b3673d017d4dc1c00b88f


