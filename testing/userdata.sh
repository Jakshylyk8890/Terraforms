#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2
echo "<h1>Hello from Jakshylyk</h1>" > /var/www/html/index.html