###
# Author: IT Infrastructure
# Description: Script to Patch all Ubuntu/Centos/Solaris/SUSE distros
###

#!/bin/bash

# Function to update Debian-based systems (e.g., Ubuntu, Debian)
update_debian() {
    echo "Updating Debian-based system..."
    sudo apt --fix-broken install
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y
    echo "Debian-based system updated."
}

# Function to update Red Hat-based systems (e.g., CentOS, RHEL, Fedora)
update_redhat() {
    echo "Updating Red Hat-based system..."
    if command -v dnf >/dev/null 2>&1; then
        sudo dnf update -y
        sudo dnf autoremove -y
    elif command -v yum >/dev/null 2>&1; then
        sudo yum update -y
        sudo yum autoremove -y
    else
        echo "Neither yum nor dnf found! Cannot proceed with update."
        exit 1
    fi
    echo "Red Hat-based system updated."
}

# Function to update Arch-based systems (e.g., Arch Linux, Manjaro)
update_arch() {
    echo "Updating Arch-based system..."
    sudo pacman -Syu --noconfirm
    echo "Arch-based system updated."
}

# Function to update SUSE-based systems (e.g., openSUSE, SLES)
update_suse() {
    echo "Updating SUSE-based system..."
    sudo zypper refresh
    sudo zypper update -y
    sudo zypper clean -a
    echo "SUSE-based system updated."
}

# Function to update Solaris-based systems (e.g, Solaris)
update_solaris() {
    echo "Updating Solaris system..."
    sudo pkg update -v
    sudo pkg upgrade -v
    sudo pkg clean -a
    echo "Solaris system updated."
}

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    # For modern systems with /etc/os-release
    . /etc/os-release
    DISTRO_NAME=$(cat /etc/os-release | grep "^ID=" | awk -F= '{print $2}' | sed 's/"//g' | head -1 )
    # DISTRO_NAME=$ID
else
    # Fallback in case /etc/os-release is missing (very rare)
    echo "Cannot determine distribution. Exiting."
    exit 1
fi

# Call the appropriate update function based on the distro
case "$DISTRO_NAME" in
    debian|ubuntu|linuxmint|raspbian)
        update_debian
        ;;
    centos|rhel|fedora|scientific)
        update_redhat
        ;;
    arch|manjaro|endeavouros)
        update_arch
        ;;
    opensuse|sles)
        update_suse
        ;;
	solaris)
		update_solaris
		;;
    *)
        echo "Unsupported Linux distribution: $DISTRO_NAME"
        exit 1
        ;;
esac

echo "System patching complete."
