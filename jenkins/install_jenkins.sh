#!/bin/bash
set -e  # Exit on errors

# Update package index
echo "Updating package index..."
sudo apt update -y

# Install dependencies
echo "Installing required dependencies..."
sudo apt install -y wget gnupg software-properties-common curl apt-transport-https unzip lsb-release

#######################
# Jenkins Installation 
#######################
echo "Adding Jenkins repository and GPG key..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
    | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "Adding Jenkins repository..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
echo "Installing Java 17..."
sudo apt install -y openjdk-17-jdk
java -version || { echo "Java installation failed. Exiting."; exit 1; }

echo "Installing Jenkins..."
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

#######################
# Terraform 
#######################
echo "Adding HashiCorp repository and installing Terraform..."
curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update -y
sudo apt install -y terraform
terraform -version

#######################
# Docker
#######################
echo "Adding Docker repository and installing Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo usermod -aG docker $USER
docker --version

#######################
# kubectl 
#######################
echo "Installing latest stable kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256
kubectl version --client

#######################
# AWS CLI 
#######################
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
aws --version

#######################
# Helm
#######################
echo "Installing latest Helm..."
HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f 4)
wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 helm-${HELM_VERSION}-linux-amd64.tar.gz
helm version

#######################
# Jenkins service status
#######################
echo "Checking Jenkins service status..."
sudo systemctl status jenkins --no-pager || {
    echo "Jenkins failed to start. Check logs with 'sudo journalctl -u jenkins'."; exit 1;
}

#######################
# Final Output
#######################
echo "Jenkins installation completed."
echo "Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080"
echo "To get the initial admin password, run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
