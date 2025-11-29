#!/bin/bash
# Korean VPN Server Entrypoint Script

set -e

WG_INTERFACE="wg0"
WG_CONFIG="/etc/wireguard/${WG_INTERFACE}.conf"
SERVER_SUBNET="10.13.13.0/24"
SERVER_IP="10.13.13.1"
DNS_SERVER="${DNS_SERVER:-1.1.1.1}"
SERVER_PORT="${SERVER_PORT:-51820}"

# Generate server keys if not exist
generate_server_keys() {
    if [ ! -f /etc/wireguard/server_private.key ]; then
        echo "[INFO] Generating server keys..."
        wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
        chmod 600 /etc/wireguard/server_private.key
    fi
}

# Create server config
create_server_config() {
    local private_key=$(cat /etc/wireguard/server_private.key)
    
    cat > "${WG_CONFIG}" << EOF
[Interface]
Address = ${SERVER_IP}/24
ListenPort = ${SERVER_PORT}
PrivateKey = ${private_key}

# NAT rules for forwarding
PostUp = iptables -A FORWARD -i %i -j ACCEPT
PostUp = iptables -A FORWARD -o %i -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -D FORWARD -o %i -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

    # Add existing peer configs if any
    if [ -d /etc/wireguard/peers ]; then
        for peer_conf in /etc/wireguard/peers/*.conf; do
            if [ -f "$peer_conf" ]; then
                echo "" >> "${WG_CONFIG}"
                cat "$peer_conf" >> "${WG_CONFIG}"
            fi
        done
    fi
}

# Enable IP forwarding
enable_forwarding() {
    echo "[INFO] Enabling IP forwarding..."
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv4.conf.all.src_valid_mark=1
}

# Start WireGuard
start_wireguard() {
    echo "[INFO] Starting WireGuard interface ${WG_INTERFACE}..."
    wg-quick up ${WG_INTERFACE}
    echo "[INFO] WireGuard interface started successfully"
    echo "[INFO] Server public key: $(cat /etc/wireguard/server_public.key)"
}

# Main
main() {
    echo "==================================="
    echo "    Korean VPN Server Starting     "
    echo "==================================="
    
    generate_server_keys
    create_server_config
    enable_forwarding
    start_wireguard
    
    echo "[INFO] VPN Server is running..."
    echo "[INFO] Listening on port ${SERVER_PORT}/UDP"
    
    # Keep container running
    tail -f /dev/null
}

main
