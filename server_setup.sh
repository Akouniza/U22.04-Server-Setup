#!/bin/bash

# Define text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Update package list and upgrade installed packages
echo -e "${YELLOW}Updating package list and upgrading installed packages...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

# Allow password authentication temporarily
echo -e "${YELLOW}Enabling password authentication temporarily...${NC}"
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Prompt for the username with basic input validation
while true; do
    read -p "Enter the username for the new sudo user: " USERNAME
    if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        echo -e "${RED}Invalid username. Please use only lowercase letters, numbers, hyphens, and underscores.${NC}"
    else
        break
    fi
done

# Create a new sudo user
echo -e "${YELLOW}Creating a new sudo user '${USERNAME}'...${NC}"
sudo adduser "${USERNAME}"
sudo usermod -aG sudo "${USERNAME}"

# Display information about the server setup
echo -e "${GREEN}Server setup complete!${NC}"
echo -e "${GREEN}Make sure to copy your SSH key to the '${USERNAME}' user's authorized_keys file before logging in.${NC}"

# Optionally, display the temporary password authentication message
echo -e "${YELLOW}Temporary: Password authentication is enabled. Remember to disable it later for security.${NC}"
