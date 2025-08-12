#!/bin/bash

set -e  # Exit on errors

# Update the package index
echo "Updating package index..."
sudo apt update -y

# Install required dependencies
echo "Installing required dependencies..."
sudo apt install -y wget gnupg software-properties-common curl

# Add Jenkins repository and GPG key
echo "Adding Jenkins repository and GPG key..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null || {
    echo "Failed to add Jenkins GPG key. Exiting."; exit 1;
}

echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

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

# Add HashiCorp GPG key and repository, then install Terraform
echo "Adding HashiCorp repository and installing Terraform..."
wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt update -y
sudo apt install -y terraform

# Add Docker GPG key and repository, then install Docker
echo "Adding Docker repository and installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo usermod -aG docker $USER

# Install specific version of kubectl (v1.21.0)
echo "Installing kubectl version 1.21.0..."
curl -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
curl -LO "https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check || { echo "kubectl checksum verification failed! Exiting."; exit 1; }
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256

# Install AWS CLI
echo "Installing AWS CLI..."
sudo apt install -y awscli

# Install Helm (specific version v3.2.4)
echo "Installing Helm version 3.2.4..."
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
tar -zxvf helm-v3.2.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 helm-v3.2.4-linux-amd64.tar.gz

# Check Jenkins service status
echo "Checking Jenkins service status..."
sudo systemctl status jenkins --no-pager || {
    echo "Jenkins failed to start. Check logs with 'sudo journalctl -u jenkins'."; exit 1;
}

# Final output
echo "Jenkins installation completed."
echo "Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080"
echo "To get the initial admin password, run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
