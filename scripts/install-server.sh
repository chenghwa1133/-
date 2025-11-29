#!/bin/bash
# Korean VPN Server Installation Script
# 한국 VPN 서버 설치 스크립트
# This script sets up a WireGuard VPN server on a Korean server

set -e

echo "========================================"
echo "    한국 VPN 서버 설치 스크립트"
echo "    Korean VPN Server Installation"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] 이 스크립트는 root 권한이 필요합니다"
    echo "[ERROR] Please run this script as root"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "[ERROR] 지원되지 않는 운영체제입니다"
    echo "[ERROR] Unsupported operating system"
    exit 1
fi

echo "[INFO] 운영체제 / OS: ${OS}"
echo ""

# Install WireGuard
install_wireguard() {
    echo "[INFO] WireGuard 설치 중... / Installing WireGuard..."
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y wireguard wireguard-tools qrencode
            ;;
        centos|rhel|rocky|almalinux)
            yum install -y epel-release
            yum install -y wireguard-tools qrencode
            ;;
        fedora)
            dnf install -y wireguard-tools qrencode
            ;;
        *)
            echo "[ERROR] 지원되지 않는 운영체제: ${OS}"
            echo "[ERROR] Unsupported OS: ${OS}"
            exit 1
            ;;
    esac
    
    echo "[INFO] WireGuard 설치 완료 / WireGuard installation complete"
}

# Enable IP forwarding
enable_forwarding() {
    echo "[INFO] IP 포워딩 활성화 중... / Enabling IP forwarding..."
    
    # Enable now
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.forwarding=1
    
    # Make persistent
    cat >> /etc/sysctl.conf << EOF

# Korean VPN - IP Forwarding
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
    
    echo "[INFO] IP 포워딩 활성화 완료 / IP forwarding enabled"
}

# Generate server keys
generate_keys() {
    echo "[INFO] 서버 키 생성 중... / Generating server keys..."
    
    mkdir -p /etc/wireguard/peers
    cd /etc/wireguard
    
    # Generate server keys
    wg genkey | tee server_private.key | wg pubkey > server_public.key
    chmod 600 server_private.key
    
    echo "[INFO] 서버 키 생성 완료 / Server keys generated"
    echo "[INFO] 공개키 / Public Key: $(cat server_public.key)"
}

# Get server's public IP
get_public_ip() {
    PUBLIC_IP=$(curl -s --connect-timeout 5 https://api.ipify.org || curl -s --connect-timeout 5 https://ifconfig.me || echo "")
    if [ -z "${PUBLIC_IP}" ]; then
        echo "[WARNING] 공개 IP를 자동 감지할 수 없습니다"
        echo "[WARNING] Could not auto-detect public IP"
        echo "[WARNING] 클라이언트 설정에서 SERVER_ENDPOINT를 수동으로 설정하세요"
        echo "[WARNING] Please set SERVER_ENDPOINT manually in client configurations"
        PUBLIC_IP="<YOUR_SERVER_IP>"
    fi
    echo "${PUBLIC_IP}"
}

# Configure WireGuard server
configure_server() {
    echo "[INFO] 서버 설정 중... / Configuring server..."
    
    SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)
    SERVER_PORT="${SERVER_PORT:-51820}"
    SERVER_SUBNET="10.13.13.1/24"
    
    # Detect main network interface
    MAIN_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    
    cat > /etc/wireguard/wg0.conf << EOF
# Korean VPN Server Configuration
# 한국 VPN 서버 설정
# Generated on: $(date)

[Interface]
Address = ${SERVER_SUBNET}
ListenPort = ${SERVER_PORT}
PrivateKey = ${SERVER_PRIVATE_KEY}

# NAT Configuration
PostUp = iptables -A FORWARD -i %i -j ACCEPT
PostUp = iptables -A FORWARD -o %i -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o ${MAIN_INTERFACE} -j MASQUERADE

PostDown = iptables -D FORWARD -i %i -j ACCEPT
PostDown = iptables -D FORWARD -o %i -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o ${MAIN_INTERFACE} -j MASQUERADE

# Add client peers below
# 아래에 클라이언트 피어 추가

EOF
    
    chmod 600 /etc/wireguard/wg0.conf
    echo "[INFO] 서버 설정 완료 / Server configuration complete"
}

# Configure firewall
configure_firewall() {
    echo "[INFO] 방화벽 설정 중... / Configuring firewall..."
    
    SERVER_PORT="${SERVER_PORT:-51820}"
    
    # UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        ufw allow ${SERVER_PORT}/udp
        echo "[INFO] UFW: 포트 ${SERVER_PORT}/udp 허용됨"
    fi
    
    # firewalld (CentOS/RHEL/Fedora)
    if command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-port=${SERVER_PORT}/udp
        firewall-cmd --reload
        echo "[INFO] firewalld: 포트 ${SERVER_PORT}/udp 허용됨"
    fi
    
    echo "[INFO] 방화벽 설정 완료 / Firewall configuration complete"
}

# Start WireGuard
start_wireguard() {
    echo "[INFO] WireGuard 시작 중... / Starting WireGuard..."
    
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0
    
    echo "[INFO] WireGuard 시작 완료 / WireGuard started"
}

# Main installation
main() {
    install_wireguard
    enable_forwarding
    generate_keys
    configure_server
    configure_firewall
    start_wireguard
    
    PUBLIC_IP=$(get_public_ip)
    SERVER_PORT="${SERVER_PORT:-51820}"
    
    echo ""
    echo "========================================"
    echo "    설치 완료! / Installation Complete!"
    echo "========================================"
    echo ""
    echo "서버 정보 / Server Information:"
    echo "  공개 IP / Public IP: ${PUBLIC_IP}"
    echo "  포트 / Port: ${SERVER_PORT}"
    echo "  공개키 / Public Key: $(cat /etc/wireguard/server_public.key)"
    echo ""
    echo "다음 단계 / Next Steps:"
    echo "1. 클라이언트를 추가하려면 add-client.sh 스크립트를 실행하세요"
    echo "   Run add-client.sh to add clients"
    echo ""
    echo "2. 상태 확인: wg show"
    echo "   Check status: wg show"
    echo ""
    echo "3. 서버 중지: systemctl stop wg-quick@wg0"
    echo "   Stop server: systemctl stop wg-quick@wg0"
    echo "========================================"
}

main
