#!/bin/bash

# Define text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to create a new sudo user
create_sudo_user() {
    while true; do
        echo -e "${CYAN}Enter the username for the new sudo user: ${NC}"
        read -p "" USERNAME
        if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            echo -e "${RED}Invalid username. Please use only lowercase letters, numbers, hyphens, and underscores.${NC}"
        else
            break
        fi
    done

    echo -e "${YELLOW}Creating a new sudo user '${USERNAME}'...${NC}"
    sudo adduser "${USERNAME}"
    sudo usermod -aG sudo "${USERNAME}"

    echo -e "${GREEN}Sudo user '${USERNAME}' created!${NC}"
    echo -e "${GREEN}Make sure to copy your SSH key to the '${USERNAME}' user's authorized_keys file before logging in.${NC}"
}

# Function to setup the server
setup_server() {
    echo -e "${YELLOW}Updating package list...${NC}"
    sudo apt-get update

    echo -e "${YELLOW}Upgrading installed packages...${NC}"
    sudo apt-get upgrade -y

    echo -e "${YELLOW}Enabling password authentication temporarily...${NC}"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
    echo -e "${YELLOW}Temporary: Password authentication is enabled. Remember to disable it later for security.${NC}"
}

# Function to delete a sudo user and its home directory
delete_sudo_user() {
    echo -e "${CYAN}Enter the username to delete: ${NC}"
    read -p "" USERNAME
    echo -e "${YELLOW}Deleting sudo user '${USERNAME}' and its home directory...${NC}"
    sudo deluser --remove-home "${USERNAME}"
    echo -e "${GREEN}Sudo user '${USERNAME}' deleted!${NC}"
}

# Function to monitor server resources
check_disk_space() {
    echo -e "${YELLOW}Checking disk space...${NC}"
    df -h
}

# Function to backup files or directories
backup_files() {
    echo -e "${CYAN}Enter the path of the file or directory to backup: ${NC}"
    read -p "" SOURCE_PATH
    echo -e "${CYAN}Enter the destination path for the backup: ${NC}"
    read -p "" DESTINATION_PATH
    echo -e "${YELLOW}Backing up '${SOURCE_PATH}' to '${DESTINATION_PATH}'...${NC}"
    sudo cp -r "${SOURCE_PATH}" "${DESTINATION_PATH}"
    echo -e "${GREEN}Backup completed!${NC}"
}

# Function to generate SSH key pair using Ed25519 algorithm
generate_ssh_key() {
    echo -e "${CYAN}Enter the email for the SSH key: ${NC}"
    read -p "" EMAIL
    echo -e "${YELLOW}Generating SSH key pair (Ed25519) for '${EMAIL}'...${NC}"
    ssh-keygen -t ed25519 -C "${EMAIL}"
    echo -e "${GREEN}SSH key pair (Ed25519) generated!${NC}"
}

# Function to configure automatic updates
configure_automatic_updates() {
    echo -e "${CYAN}Enable automatic updates? (yes/no): ${NC}"
    read -p "" AUTO_UPDATE
    if [[ "${AUTO_UPDATE}" == "yes" ]]; then
        echo -e "${YELLOW}Configuring automatic updates...${NC}"
        sudo apt-get install -y unattended-upgrades
        echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
        echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
        echo 'APT::Periodic::AutocleanInterval "7";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
        echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
        echo -e "${GREEN}Automatic updates configured!${NC}"
    else
        echo -e "${YELLOW}Automatic updates not configured.${NC}"
    fi
}

# Function to configure NTP
configure_ntp() {
    echo -e "${CYAN}Enable NTP service? (yes/no): ${NC}"
    read -p "" ENABLE_NTP
    if [[ "${ENABLE_NTP}" == "yes" ]]; then
        echo -e "${YELLOW}Configuring NTP service...${NC}"
        sudo apt-get install -y ntp
        sudo systemctl enable ntp
        sudo systemctl start ntp
        echo -e "${GREEN}NTP service configured!${NC}"
    else
        echo -e "${YELLOW}NTP service not configured.${NC}"
    fi
}

# Function to allow or delete UFW rules
ufw_allow_delete_rule() {
    echo -e "${CYAN}Enter the IP address (theip) to allow or delete rule (e.g., 192.168.1.1): ${NC}"
    read -p "" IP_ADDRESS
    echo -e "${CYAN}Enter the corresponding port (thecorresponding port) to allow or delete rule (e.g., 22): ${NC}"
    read -p "" PORT

    echo -e "${CYAN}Do you want to allow or delete the UFW rule? (allow/delete): ${NC}"
    read -p "" ACTION

    if [[ "${ACTION}" == "allow" ]]; then
        sudo ufw allow from "${IP_ADDRESS}/32" to any port "${PORT}"
        echo -e "${GREEN}UFW rule allowing access from ${IP_ADDRESS} to port ${PORT} added!${NC}"
    elif [[ "${ACTION}" == "delete" ]]; then
        sudo ufw delete allow from "${IP_ADDRESS}/32" to any port "${PORT}"
        echo -e "${GREEN}UFW rule allowing access from ${IP_ADDRESS} to port ${PORT} deleted!${NC}"
    else
        echo -e "${RED}Invalid action. Please choose 'allow' or 'delete'.${NC}"
    fi
}

# Display menu for setup and additional options
echo -e "${YELLOW}Select an option:${NC}"
echo -e "  ${CYAN}1) Setup Server${NC}"
echo -e "  ${CYAN}2) Add a Sudo User${NC}"
echo -e "  ${CYAN}3) Delete a Sudo User and Home Directory${NC}"
echo -e "  ${CYAN}4) Check Disk Space${NC}"
echo -e "  ${CYAN}5) Backup Files or Directories${NC}"
echo -e "  ${CYAN}6) Generate SSH Key Pair (Ed25519)${NC}"
echo -e "  ${CYAN}7) Configure Automatic Updates${NC}"
echo -e "  ${CYAN}8) Configure NTP${NC}"
echo -e "  ${CYAN}9) Allow or Delete UFW Rule${NC}"

echo -e "${CYAN}Enter the number of your choice: ${NC}"
read -p "" CHOICE

case "$CHOICE" in
    1)
        # Setup Server
        setup_server
        ;;
    2)
        # Add a Sudo User
        create_sudo_user
        ;;
    3)
        # Delete a Sudo User and Home Directory
        delete_sudo_user
        ;;
    4)
        # Check Disk Space
        check_disk_space
        ;;
    5)
        # Backup Files or Directories
        backup_files
        ;;
    6)
        # Generate SSH Key Pair (Ed25519)
        generate_ssh_key
        ;;
    7)
        # Configure Automatic Updates
        configure_automatic_updates
        ;;
    8)
        # Configure NTP
        configure_ntp
        ;;
    9)
        # Allow or Delete UFW Rule
        ufw_allow_delete_rule
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        exit 1
        ;;
esac
