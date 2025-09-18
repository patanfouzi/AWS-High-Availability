#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Install nginx
apt-get update -y
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# Install CloudWatch Agent (minimal setup)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/cwagent.deb
dpkg -i /tmp/cwagent.deb || apt-get -f install -y
