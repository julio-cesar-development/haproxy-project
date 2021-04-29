#!/bin/bash

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
  echo "starting user-data $0"

  sleep 10

  PRIVATE_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
  echo "PRIVATE_IP $PRIVATE_IP"

  yum update -y
  yum install -y httpd.x86_64

  echo "IP $PRIVATE_IP" | tee /var/www/html/index.html
  echo "OK" | tee /var/www/html/healthcheck

  systemctl enable httpd.service
  systemctl start httpd.service

  systemctl status httpd.service
