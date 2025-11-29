# 한국 VPN (Korean VPN for Use Abroad)

해외에서 한국 서비스에 접속할 수 있는 WireGuard 기반 VPN 솔루션입니다.

A WireGuard-based VPN solution for accessing Korean services from abroad.

## 주요 기능 / Features

- **빠른 속도**: WireGuard의 최신 암호화 기술로 빠른 연결 속도
- **보안**: 최신 암호화 프로토콜 사용 (ChaCha20, Poly1305)
- **간편한 설치**: Docker 또는 스크립트로 쉽게 설치
- **모바일 지원**: iOS, Android 앱 지원
- **QR 코드**: 모바일 설정을 위한 QR 코드 생성

## 사전 요구사항 / Prerequisites

### 서버 요구사항 / Server Requirements
- 한국에 위치한 서버 (클라우드 서버 추천: AWS, GCP, Azure, Naver Cloud, KT Cloud 등)
- Ubuntu 20.04/22.04 또는 CentOS 7/8
- 최소 512MB RAM
- 공인 IP 주소

### 클라이언트 요구사항 / Client Requirements
- Windows, macOS, Linux, iOS, Android 중 하나
- WireGuard 클라이언트 앱

## 빠른 시작 / Quick Start

### 방법 1: Docker 사용 (권장)

```bash
# 서버에서 실행
cd vpn-server
docker-compose up -d

# 클라이언트 설정 파일 확인
ls config/peer*/peer*.conf
```

### 방법 2: 직접 설치

```bash
# 서버 설치
sudo ./scripts/install-server.sh

# 클라이언트 추가
sudo ./scripts/add-client.sh my-phone 2
sudo ./scripts/add-client.sh my-laptop 3
```

## 상세 설치 가이드 / Detailed Installation Guide

### 서버 설치 / Server Setup

1. **한국 서버 준비**
   - AWS Seoul 리전, Naver Cloud, KT Cloud 등에서 서버 생성
   - Ubuntu 22.04 LTS 권장
   - 포트 51820/UDP 개방

2. **서버 설치 스크립트 실행**
   ```bash
   # 저장소 클론
   git clone https://github.com/your-repo/korean-vpn.git
   cd korean-vpn
   
   # 설치 스크립트 실행
   sudo chmod +x scripts/*.sh
   sudo ./scripts/install-server.sh
   ```

3. **클라이언트 추가**
   ```bash
   # 첫 번째 클라이언트 (예: 휴대폰)
   sudo ./scripts/add-client.sh my-phone 2
   
   # 두 번째 클라이언트 (예: 노트북)  
   sudo ./scripts/add-client.sh my-laptop 3
   ```

### 클라이언트 설정 / Client Setup

#### Windows
1. [WireGuard 다운로드](https://www.wireguard.com/install/)
2. 설치 후 "Import tunnel(s) from file" 클릭
3. 서버에서 받은 .conf 파일 선택
4. "Activate" 클릭하여 연결

#### macOS
1. App Store에서 WireGuard 설치
2. "Import tunnel(s) from file" 클릭
3. .conf 파일 선택
4. 연결 활성화

#### iOS
1. App Store에서 WireGuard 설치
2. QR 코드 스캔 또는 설정 파일 가져오기
3. VPN 연결 활성화

#### Android
1. Play Store에서 WireGuard 설치
2. QR 코드 스캔 또는 설정 파일 가져오기
3. VPN 연결 활성화

#### Linux
```bash
# 설치
sudo apt install wireguard

# 설정 파일 복사
sudo cp my-phone.conf /etc/wireguard/wg0.conf

# 연결
sudo wg-quick up wg0

# 연결 해제
sudo wg-quick down wg0
```

## 명령어 참조 / Command Reference

### 서버 명령어 / Server Commands

```bash
# WireGuard 상태 확인
sudo wg show

# 서비스 재시작
sudo systemctl restart wg-quick@wg0

# 로그 확인
sudo journalctl -u wg-quick@wg0

# 클라이언트 추가 후 설정 리로드
sudo wg syncconf wg0 <(wg-quick strip wg0)
```

### 클라이언트 명령어 / Client Commands

```bash
# VPN 연결
sudo wg-quick up wg0

# VPN 연결 해제
sudo wg-quick down wg0

# 연결 상태 확인
sudo wg show

# IP 확인
curl https://api.ipify.org
```

## 문제 해결 / Troubleshooting

### 연결이 안 될 때 / Connection Issues

1. **서버 방화벽 확인**
   ```bash
   sudo ufw allow 51820/udp
   # 또는
   sudo firewall-cmd --add-port=51820/udp --permanent
   sudo firewall-cmd --reload
   ```

2. **IP 포워딩 확인**
   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   # 1이 출력되어야 함
   ```

3. **키 확인**
   - 서버와 클라이언트의 공개키/개인키가 올바른지 확인

### 느린 속도 / Slow Speed

- MTU 값 조정: 클라이언트 설정에 `MTU = 1280` 추가
- 서버 위치 확인: 한국 내 서버인지 확인

### DNS 문제 / DNS Issues

클라이언트 설정에서 DNS 변경:
```
DNS = 168.126.63.1, 168.126.63.2
```
(KT DNS 서버)

## 보안 권장사항 / Security Recommendations

1. **정기적인 키 교체**: 3-6개월마다 새 키 생성
2. **로그 모니터링**: 비정상적인 접속 시도 확인
3. **서버 업데이트**: 정기적인 보안 패치 적용
4. **사용하지 않는 클라이언트 제거**: 분실된 기기의 피어 제거

## 라이선스 / License

MIT License

## 문의 / Contact

이슈나 문의사항은 GitHub Issues를 통해 문의해주세요.
For issues or questions, please use GitHub Issues.
