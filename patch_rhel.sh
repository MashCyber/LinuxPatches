#!/bin/bash

# Enable error handling
set -e

# Log file
LOG_FILE="/var/log/rhel_patch.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   log_message "This script must be run as root. Exiting."
   exit 1
fi

log_message "Starting RHEL patching process..."

# Prompt for Red Hat Subscription Manager credentials
read -p "Enter your RHSM username: " RHSM_USERNAME
read -s -p "Enter your RHSM password: " RHSM_PASSWORD
echo

# Check and register the system if not already registered
if ! subscription-manager status &>/dev/null; then
    log_message "System is not registered. Attempting to register with RHSM."
    subscription-manager register --username="$RHSM_USERNAME" --password="$RHSM_PASSWORD"
    subscription-manager attach --auto
else
    log_message "System is already registered."
fi

# Update all installed packages
log_message "Updating all installed packages..."
yum update -y

# Check if a kernel update was applied
KERNEL_UPDATED=0
if [[ $(needs-restarting -r || true) ]]; then
    KERNEL_UPDATED=1
    log_message "Kernel updates were applied. A system reboot is required."
else
    log_message "No kernel updates detected."
fi

# Clean up unused packages and cache
log_message "Cleaning up unused packages and cache..."
yum autoremove -y
yum clean all

# Reboot if kernel or critical updates were applied
if [[ $KERNEL_UPDATED -eq 1 ]]; then
    log_message "Rebooting the system..."
    reboot
else
    log_message "No reboot required. Patching process complete."
fi
