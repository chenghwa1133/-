# 한국 VPN 클라이언트 설치 가이드
# Korean VPN Client Installation Guide

이 문서는 각 플랫폼별 WireGuard VPN 클라이언트 설치 방법을 안내합니다.

## Windows 설치 / Windows Installation

### 1. WireGuard 다운로드

1. https://www.wireguard.com/install/ 접속
2. "Download Windows Installer" 클릭
3. 다운로드된 설치 파일 실행

### 2. VPN 설정

1. WireGuard 앱 실행
2. "Add Tunnel" → "Import tunnel(s) from file" 클릭
3. 서버에서 받은 `.conf` 파일 선택
4. "Activate" 버튼 클릭

### 3. 연결 확인

- 상태가 "Active"로 표시되면 연결 완료
- https://ip.pe.kr 에서 한국 IP 확인

---

## macOS 설치 / macOS Installation

### 1. WireGuard 설치

**App Store 사용:**
1. App Store에서 "WireGuard" 검색
2. 설치

**Homebrew 사용:**
```bash
brew install wireguard-tools
```

### 2. GUI 앱으로 설정

1. WireGuard 앱 실행
2. "Import tunnel(s) from file" 클릭
3. `.conf` 파일 선택
4. "Allow" 클릭하여 시스템 확장 허용
5. 터널 활성화

### 3. 터미널로 설정

```bash
# 설정 파일 복사
sudo mkdir -p /etc/wireguard
sudo cp your-config.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# VPN 연결
sudo wg-quick up wg0

# VPN 연결 해제
sudo wg-quick down wg0
```

---

## iOS 설치 / iOS Installation

### 1. WireGuard 앱 설치

1. App Store에서 "WireGuard" 검색
2. 설치

### 2. VPN 설정 (QR 코드)

1. WireGuard 앱 실행
2. "+" 버튼 탭
3. "Create from QR code" 선택
4. 서버에서 생성된 QR 코드 스캔
5. 터널 이름 입력 (예: "Korean VPN")
6. "Save" 탭
7. VPN 설정 추가 허용

### 3. VPN 설정 (파일)

1. `.conf` 파일을 이메일이나 AirDrop으로 전송
2. 파일 탭하여 WireGuard로 열기
3. "Allow" 탭하여 저장

### 4. 연결

1. WireGuard 앱에서 생성된 터널 탭
2. 스위치를 켜서 연결

---

## Android 설치 / Android Installation

### 1. WireGuard 앱 설치

1. Play Store에서 "WireGuard" 검색
2. 설치

### 2. VPN 설정 (QR 코드)

1. WireGuard 앱 실행
2. "+" 버튼 탭
3. "SCAN FROM QR CODE" 선택
4. QR 코드 스캔
5. 터널 이름 입력
6. 저장

### 3. VPN 설정 (파일)

1. `.conf` 파일을 기기에 다운로드
2. WireGuard 앱에서 "+" 탭
3. "IMPORT FROM FILE OR ARCHIVE" 선택
4. 파일 선택

### 4. 연결

1. 생성된 터널 탭
2. 스위치를 켜서 연결

---

## Linux 설치 / Linux Installation

### Ubuntu/Debian

```bash
# 설치
sudo apt update
sudo apt install wireguard wireguard-tools resolvconf

# 설정 파일 복사
sudo cp your-config.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# VPN 연결
sudo wg-quick up wg0

# 부팅시 자동 연결
sudo systemctl enable wg-quick@wg0
```

### CentOS/RHEL/Rocky

```bash
# 설치
sudo yum install epel-release
sudo yum install wireguard-tools

# 설정 파일 복사
sudo cp your-config.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# VPN 연결
sudo wg-quick up wg0
```

### Fedora

```bash
# 설치
sudo dnf install wireguard-tools

# 설정 파일 복사
sudo cp your-config.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# VPN 연결
sudo wg-quick up wg0
```

### Arch Linux

```bash
# 설치
sudo pacman -S wireguard-tools

# 설정 파일 복사
sudo cp your-config.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# VPN 연결
sudo wg-quick up wg0
```

---

## 연결 확인 / Verify Connection

VPN 연결 후 다음 사이트에서 한국 IP인지 확인하세요:

- https://ip.pe.kr
- https://whatismyipaddress.com
- https://api.ipify.org

한국 IP가 표시되면 성공적으로 연결된 것입니다!

---

## 문제 해결 / Troubleshooting

### 연결이 안 되는 경우

1. 인터넷 연결 확인
2. 설정 파일의 서버 IP와 포트 확인
3. 서버 방화벽에서 51820/UDP 개방 확인

### DNS 문제

설정 파일의 DNS 서버를 다음으로 변경:
```
DNS = 168.126.63.1, 168.126.63.2
```

### 속도가 느린 경우

설정 파일에 MTU 추가:
```
[Interface]
...
MTU = 1280
```
