#!/bin/bash
SERVER_IP="192.168.1.120"  # Replace with your server IP
echo "Connecting to Sunshine server at $SERVER_IP..."
moonlight pair "$SERVER_IP"
moonlight stream "$SERVER_IP" "Desktop"
