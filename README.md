My Ubuntu Server Script
Overview
This script aim to automate the setup of an Ubuntu 22(0).04 server, including package updates, temporary enablement of password authentication for SSH, and the creation of a new sudo user.

Download

    curl -O https://raw.githubusercontent.com/Akouniza/U22.04-Server-Setup/main/server_setup.sh

Features

    Updates package list and upgrades installed packages.
    Temporarily allows password authentication for SSH.
    Prompts for a username and creates a new sudo user.
    Provides information about the server setup, including a reminder to disable password authentication later for security.

Usage

    Run the script on your Ubuntu 22.04 server.
    Follow the prompts to enter the desired username for the new sudo user.
    Copy your SSH key to the user's authorized_keys file.
    Optionally, disable password authentication in the SSH configuration for enhanced security.

Note

    The script is intended for temporary password authentication to facilitate SSH key setup. Ensure to disable password authentication after key setup.

How to Run

    Save the script to a file (e.g., setup_server.sh).
    Make the script executable: chmod +x setup_server.sh.
    Run the script with elevated privileges: sudo ./setup_server.sh.
