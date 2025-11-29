#!/bin/bash
# Korean VPN - Add Client Script
# 한국 VPN - 클라이언트 추가 스크립트

set -e

# Configuration
SERVER_PUBLIC_KEY_FILE="${SERVER_PUBLIC_KEY_FILE:-/etc/wireguard/server_public.key}"

# Get server endpoint - require explicit setting or auto-detect
if [ -z "${SERVER_ENDPOINT}" ]; then
    # Try to auto-detect public IP
    PUBLIC_IP=$(curl -s --connect-timeout 5 https://api.ipify.org || curl -s --connect-timeout 5 https://ifconfig.me || echo "")
    if [ -z "${PUBLIC_IP}" ]; then
        echo "[ERROR] SERVER_ENDPOINT가 설정되지 않았고 공개 IP를 자동 감지할 수 없습니다"
        echo "[ERROR] SERVER_ENDPOINT not set and could not auto-detect public IP"
        echo ""
        echo "다음 명령으로 실행하세요 / Run with:"
        echo "  SERVER_ENDPOINT=your-server-ip:51820 $0 $@"
        exit 1
    fi
    SERVER_ENDPOINT="${PUBLIC_IP}:51820"
    echo "[INFO] 자동 감지된 서버 엔드포인트 / Auto-detected server endpoint: ${SERVER_ENDPOINT}"
fi
DNS_SERVER="${DNS_SERVER:-1.1.1.1,8.8.8.8}"
BASE_IP="10.13.13"
PEERS_DIR="/etc/wireguard/peers"

usage() {
    echo "사용법 / Usage:"
    echo "  $0 <client_name> [client_number]"
    echo ""
    echo "예시 / Example:"
    echo "  $0 my-phone 2"
    echo "  $0 my-laptop 3"
    echo ""
    echo "client_number는 2-254 사이의 숫자입니다 (1은 서버용)"
    echo "client_number should be between 2-254 (1 is reserved for server)"
    exit 1
}

if [ -z "$1" ]; then
    usage
fi

CLIENT_NAME="$1"

# Calculate next available client number if not provided
if [ -z "$2" ]; then
    # Find highest used client number from existing peer configs
    HIGHEST_NUM=1
    if [ -d "${PEERS_DIR}" ]; then
        for peer_dir in ${PEERS_DIR}/*/; do
            if [ -d "$peer_dir" ]; then
                # Extract IP from client config if exists
                for conf_file in ${peer_dir}*.conf; do
                    if [ -f "$conf_file" ] && [ "$(basename "$conf_file")" != "server_peer.conf" ]; then
                        IP_NUM=$(grep -E "^Address\s*=" "$conf_file" 2>/dev/null | sed -E 's/.*\.([0-9]+)\/.*/\1/' || echo "")
                        if [ -n "$IP_NUM" ] && [ "$IP_NUM" -gt "$HIGHEST_NUM" ] 2>/dev/null; then
                            HIGHEST_NUM=$IP_NUM
                        fi
                    fi
                done
            fi
        done
    fi
    CLIENT_NUM=$((HIGHEST_NUM + 1))
    echo "[INFO] 자동 할당된 클라이언트 번호 / Auto-assigned client number: ${CLIENT_NUM}"
else
    CLIENT_NUM="$2"
fi

# Validate client number
if [ "$CLIENT_NUM" -lt 2 ] || [ "$CLIENT_NUM" -gt 254 ]; then
    echo "[ERROR] 클라이언트 번호는 2-254 사이여야 합니다"
    echo "[ERROR] Client number must be between 2-254"
    exit 1
fi

CLIENT_IP="${BASE_IP}.${CLIENT_NUM}"
PEER_DIR="${PEERS_DIR}/${CLIENT_NAME}"

# Create directories
mkdir -p "${PEER_DIR}"

echo "========================================"
echo "  한국 VPN 클라이언트 생성"
echo "  Korean VPN Client Generation"
echo "========================================"
echo ""
echo "클라이언트 이름 / Client Name: ${CLIENT_NAME}"
echo "클라이언트 IP / Client IP: ${CLIENT_IP}"
echo ""

# Generate client keys
wg genkey | tee "${PEER_DIR}/private.key" | wg pubkey > "${PEER_DIR}/public.key"
chmod 600 "${PEER_DIR}/private.key"

CLIENT_PRIVATE_KEY=$(cat "${PEER_DIR}/private.key")
CLIENT_PUBLIC_KEY=$(cat "${PEER_DIR}/public.key")
SERVER_PUBLIC_KEY=$(cat "${SERVER_PUBLIC_KEY_FILE}")

# Create client configuration
cat > "${PEER_DIR}/${CLIENT_NAME}.conf" << EOF
# Korean VPN Client Configuration
# 한국 VPN 클라이언트 설정
# Client: ${CLIENT_NAME}

[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/32
DNS = ${DNS_SERVER}

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${SERVER_ENDPOINT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

# Create peer config for server
cat > "${PEER_DIR}/server_peer.conf" << EOF
# Peer: ${CLIENT_NAME}
[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${CLIENT_IP}/32
EOF

echo "[INFO] 클라이언트 설정 파일이 생성되었습니다"
echo "[INFO] Client configuration files created:"
echo "  - ${PEER_DIR}/${CLIENT_NAME}.conf (클라이언트용 / for client)"
echo "  - ${PEER_DIR}/server_peer.conf (서버에 추가할 설정 / for server)"
echo ""

# Generate QR code if qrencode is available
if command -v qrencode &> /dev/null; then
    echo "[INFO] QR 코드 생성 중... / Generating QR code..."
    qrencode -t ansiutf8 < "${PEER_DIR}/${CLIENT_NAME}.conf"
    qrencode -o "${PEER_DIR}/${CLIENT_NAME}.png" < "${PEER_DIR}/${CLIENT_NAME}.conf"
    echo ""
    echo "[INFO] QR 코드가 저장되었습니다 / QR code saved: ${PEER_DIR}/${CLIENT_NAME}.png"
fi

echo ""
echo "========================================"
echo "다음 단계 / Next Steps:"
echo "1. 서버의 wg0.conf에 server_peer.conf 내용을 추가하세요"
echo "   Add server_peer.conf content to server's wg0.conf"
echo ""
echo "2. 서버에서 'wg syncconf wg0 <(wg-quick strip wg0)' 실행"
echo "   Run 'wg syncconf wg0 <(wg-quick strip wg0)' on server"
echo ""
echo "3. ${CLIENT_NAME}.conf를 클라이언트에 복사하거나 QR 코드 스캔"
echo "   Copy ${CLIENT_NAME}.conf to client or scan QR code"
echo "========================================"
