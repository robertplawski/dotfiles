#!/bin/bash
set -e

info() { echo -e "\e[1;34m[INFO]\e[0m $1"; }

# Directory where this setup script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME/.local/share/applications"
mkdir -p "$DEST_DIR"

# Ask for role
echo "Do you want this computer to act as a Server or Client? [server/client]"
read -r CHOICE
CHOICE=$(echo "$CHOICE" | tr '[:upper:]' '[:lower:]')

# Create helper scripts in the same folder
cat > "$SCRIPT_DIR/disconnect_clients.sh" <<'EOF'
#!/bin/bash
echo "Disconnecting all connected clients..."
systemctl restart sunshine --user
echo "All clients disconnected."
EOF
chmod +x "$SCRIPT_DIR/disconnect_clients.sh"

cat > "$SCRIPT_DIR/start_moonlight.sh" <<'EOF'
#!/bin/bash
SERVER_IP="192.168.1.120"  # Replace with your server IP
echo "Connecting to Sunshine server at $SERVER_IP..."
moonlight pair "$SERVER_IP"
moonlight stream "$SERVER_IP" "Desktop"
EOF
chmod +x "$SCRIPT_DIR/start_moonlight.sh"

# Generate .desktop files dynamically
cat > "$SCRIPT_DIR/server.desktop" <<EOF
[Desktop Entry]
Name=Disconnect all clients
Comment=Disconnect all connected clients
Exec=bash -c 'DIR="\$(dirname "\$(realpath "%k")")"; "\$DIR/disconnect_clients.sh"'
Icon=network-server
Terminal=true
Type=Application
Categories=Utility;
EOF

cat > "$SCRIPT_DIR/client.desktop" <<EOF
[Desktop Entry]
Name=Moonlight Client
Comment=Connect to a Sunshine server
Exec=bash -c 'DIR="\$(dirname "\$(realpath "%k")")"; "\$DIR/start_moonlight.sh"'
Icon=computer
Terminal=false
Type=Application
Categories=Network;
EOF
# Install corresponding .desktop and software
case $CHOICE in
    server)
        cp "$SCRIPT_DIR/server.desktop" "$DEST_DIR/"
        chmod +x "$DEST_DIR/server.desktop"
        info "Server desktop installed for Rofi."

        info "Installing and enabling Sunshine..."
        sudo dnf copr enable lizardbyte/stable -y
        sudo dnf install Sunshine -y
        sudo setcap cap_sys_admin+p "$(readlink -f "$(which sunshine)")"
        systemctl --user enable sunshine --now
sudo firewall-cmd --permanent --add-port=47984/tcp
sudo firewall-cmd --permanent --add-port=48010/tcp
sudo firewall-cmd --permanent --add-port=47989/tcp
sudo firewall-cmd --permanent --add-port=47999/udp
sudo firewall-cmd --reload
        info "Sunshine installed and enabled."
        ;;
    client)
        cp "$SCRIPT_DIR/client.desktop" "$DEST_DIR/"
        chmod +x "$DEST_DIR/client.desktop"
        info "Client desktop installed for Rofi."

        info "Installing Moonlight..."
        sudo dnf copr enable ferdiu/moonlight -y
        sudo dnf install moonlight-qt -y
        info "Moonlight installed."
        ;;
    *)
        echo "Invalid choice. Please run the script again and choose 'server' or 'client'."
        ;;
esac

info "Setup complete. You can now launch your role from Rofi."

