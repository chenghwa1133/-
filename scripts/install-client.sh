#!/bin/bash
# Korean VPN Client Setup Script
# 한국 VPN 클라이언트 설치 스크립트

set -e

echo "========================================"
echo "   한국 VPN 클라이언트 설치"
echo "   Korean VPN Client Installation"
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
    exit 1
fi

echo "[INFO] 운영체제 / OS: ${OS}"
echo ""

# Install WireGuard client
install_wireguard() {
    echo "[INFO] WireGuard 설치 중... / Installing WireGuard..."
    
    case $OS in
        ubuntu|debian)
            apt-get update
            apt-get install -y wireguard wireguard-tools resolvconf
            ;;
        centos|rhel|rocky|almalinux)
            yum install -y epel-release
            yum install -y wireguard-tools
            ;;
        fedora)
            dnf install -y wireguard-tools
            ;;
        arch|manjaro)
            pacman -S --noconfirm wireguard-tools
            ;;
        *)
            echo "[ERROR] 지원되지 않는 운영체제: ${OS}"
            exit 1
            ;;
    esac
    
    echo "[INFO] WireGuard 설치 완료"
}

# Setup configuration
setup_config() {
    local config_file="$1"
    
    if [ -z "$config_file" ]; then
        echo "[ERROR] 설정 파일을 지정해주세요"
        echo "[ERROR] Please specify a configuration file"
        echo ""
        echo "사용법 / Usage: $0 <config_file.conf>"
        exit 1
    fi
    
    if [ ! -f "$config_file" ]; then
        echo "[ERROR] 파일을 찾을 수 없습니다: $config_file"
        echo "[ERROR] File not found: $config_file"
        exit 1
    fi
    
    # Copy config to WireGuard directory
    cp "$config_file" /etc/wireguard/wg0.conf
    chmod 600 /etc/wireguard/wg0.conf
    
    echo "[INFO] 설정 파일 설치 완료 / Configuration installed"
}

# Start VPN connection
start_vpn() {
    echo "[INFO] VPN 연결 중... / Connecting to VPN..."
    
    wg-quick up wg0
    
    echo "[INFO] VPN 연결 완료! / VPN connected!"
}

# Check connection
check_connection() {
    echo ""
    echo "[INFO] 연결 상태 확인 중... / Checking connection..."
    echo ""
    
    # Show WireGuard status
    wg show
    
    echo ""
    
    # Check IP (should show Korean IP)
    echo "[INFO] 현재 IP 확인 / Checking current IP..."
    NEW_IP=$(curl -s https://api.ipify.org)
    echo "현재 IP / Current IP: ${NEW_IP}"
    
    # Check IP location
    echo ""
    echo "[INFO] IP 위치 확인 / Checking IP location..."
    curl -s "https://ipinfo.io/${NEW_IP}" 2>/dev/null || echo "위치 정보를 가져올 수 없습니다"
}

# Main
main() {
    local config_file="$1"
    
    install_wireguard
    setup_config "$config_file"
    start_vpn
    check_connection
    
    echo ""
    echo "========================================"
    echo "   VPN 연결 완료! / VPN Connected!"
    echo "========================================"
    echo ""
    echo "명령어 / Commands:"
    echo "  연결 끊기 / Disconnect: wg-quick down wg0"
    echo "  다시 연결 / Reconnect: wg-quick up wg0"
    echo "  상태 확인 / Status: wg show"
    echo "========================================"
}

main "$1"
