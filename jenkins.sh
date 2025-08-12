#!/bin/bash

set -e  # Exit on errors

# Update the package index
echo "Updating package index..."
sudo apt update -y

# Install required dependencies
echo "Installing required dependencies..."
sudo apt install -y wget gnupg software-properties-common

# Add Jenkins repository and GPG key
echo "Adding Jenkins repository and GPG key..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
if [ $? -ne 0 ]; then
    echo "Failed to add Jenkins GPG key. Exiting."
    exit 1
fi

echo "Adding Jenkins repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the package index again
echo "Updating package index after adding Jenkins repository..."
sudo apt update -y

# Install Java 17 if not already installed
echo "Installing Java 17..."
sudo apt install -y openjdk-17-jdk

# Verify Java installation
echo "Verifying Java installation..."
java -version || { echo "Java installation failed. Exiting."; exit 1; }

# Install Jenkins
echo "Installing Jenkins..."
sudo apt install -y jenkins

# Start and enable Jenkins service
echo "Starting and enabling Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Check Jenkins service status
sudo systemctl status jenkins || { echo "Jenkins failed to start. Check logs with 'sudo journalctl -u jenkins'."; exit 1; }

echo "Jenkins installation completed."
echo "Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080"
echo "To get the initial admin password, run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

