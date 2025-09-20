#!/bin/bash
SERVER_IP="192.168.1.120"  # Replace with your server IP
echo "Connecting to Sunshine server at $SERVER_IP..."
/usr/bin/moonlight-qt stream "$SERVER_IP"
