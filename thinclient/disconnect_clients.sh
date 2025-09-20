#!/bin/bash
echo "Disconnecting all connected clients..."
systemctl restart sunshine --user
echo "All clients disconnected."
