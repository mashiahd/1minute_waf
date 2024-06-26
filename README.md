<img src="https://raw.githubusercontent.com/mashiahd/1minute_waf/main/img/logo.jpg" alt="logo" width="200"/>

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
    - [Cloning](#cloning)
  - [Usage](#usage)
    - [Command Line Arguments](#command-line-arguments)
    - [Default Values](#default-values)
  - [Troubleshooting](#troubleshooting)
  - [License](https://github.com/mashiahd/1minute_waf/blob/main/LICENSE)

## Features

- Direct install on host or vm using vm script
- Install on Proxmox 
- Install Nginx with ModSecurity 3 support
- Automatic detection and removal of prior Nginx installations
- Customizable Nginx and ModSecurity versions
- Supports automatic service restarts
- Fall-back mechanism for downloading utility functions using `wget` if `curl` is not available

## Support Operating Systems

- A debain linux-based operating system (tested on ubuntu 22.04.01)
- A Proxmox VE 7.4-11 Minimum
- A Proxmox VE 8 Is in Testing

## Prerequisites
- wget installed
- Root privileges for installation
- Network connection for downloading necessary files

## Installation

### Host/VM
Download and install via bash on your local machine:

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/mashiahd/1minute_waf/main/platform/vm/modsec_nginx.sh)"
```
[Running With Default Values](#default-values)
### Proxmox VE (lxc)
Download and install via bash on lxc conatiner (Linux Container):

```bash
sudo bash -c "$(wget -qLO - https://raw.githubusercontent.com/mashiahd/1minute_waf/main/platform/proxmox_ct/modsec_nginx_proxmox.sh)"
```
[Running With Default Values](#default-values)

### Cloning
If repository cloned run the script with or without command-line arguments:

#### Host/VM

```bash
sudo chmod +x ./plaform/vm/modsec_nginx.sh
sudo ./plaform/vm/modsec_nginx.sh [options]
```
> [!NOTE]
> The script still calls utils.func from this github - will be fixed.

### Proxmox VE (lxc)

```bash
sudo chmod +x ./plaform/proxmox_ct/modsec_nginx_proxmox.sh
sudo ./plaform/proxmox_ct/modsec_nginx_proxmox.sh [options]
```
> [!NOTE]
> The script still calls utils.func and modsec_nginx.sh from this github - will be fixed.


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


