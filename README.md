# 1-Minute WAF Installer

This repository contains a bash script for installing Nginx with ModSecurity 3 support. The script also includes features for checking and managing previous Nginx installations, and supports automatic service restarts.

## Table of Contents

- [1-Minute WAF Installer](#1-minute-waf-installer)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Command Line Arguments](#command-line-arguments)
    - [Default Values](#default-values)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [License](#license)

## Features

- Install Nginx with ModSecurity 3 support
- Automatic detection and removal of prior Nginx installations
- Customizable Nginx and ModSecurity versions
- Supports automatic service restarts
- Fall-back mechanism for downloading utility functions using `wget` if `curl` is not available

## Prerequisites

- A Unix-based operating system (Linux, macOS, etc.)
- Root privileges for installation
- Network connection for downloading necessary files

## Installation

Clone the repository to your local machine:

```bash
git clone https://github.com/yourusername/1minwaf.git
cd 1minwaf
