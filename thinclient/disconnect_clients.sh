#!/bin/bash
echo "Disconnecting all connected clients..."
systemctl restart sunshine --user
echo "All clients disconnected."
sudo firewall-cmd --permanent --add-port=47984/tcp
sudo firewall-cmd --permanent --add-port=48010/tcp
sudo firewall-cmd --permanent --add-port=47989/tcp
sudo firewall-cmd --permanent --add-port=47999/udp
sudo firewall-cmd --reload
