# 한국 VPN (Korean VPN)

🌏 해외에서 한국 서비스에 접속할 수 있는 WireGuard 기반 VPN 솔루션

A WireGuard-based VPN solution for accessing Korean services from abroad.

## 🚀 주요 기능 / Features

- **빠른 연결** - WireGuard의 최신 암호화 기술 사용
- **간편한 설치** - Docker 또는 스크립트로 쉽게 설치
- **크로스 플랫폼** - Windows, macOS, Linux, iOS, Android 지원
- **QR 코드 지원** - 모바일 기기 간편 설정

## 📋 프로젝트 구조 / Project Structure

```
├── vpn-server/           # VPN 서버 설정
│   ├── docker-compose.yml
│   ├── Dockerfile
│   └── entrypoint.sh
├── vpn-client/           # 클라이언트 설정 템플릿
│   └── client-template.conf
├── scripts/              # 설치 및 관리 스크립트
│   ├── install-server.sh
│   ├── install-client.sh
│   └── add-client.sh
└── docs/                 # 상세 문서
    ├── README-ko.md
    └── CLIENT-SETUP.md
```

## ⚡ 빠른 시작 / Quick Start

### Docker 사용 (권장)

```bash
cd vpn-server
docker-compose up -d
```

### 직접 설치

```bash
# 서버에서
sudo ./scripts/install-server.sh

# 클라이언트 추가
sudo ./scripts/add-client.sh my-phone 2
```

## 📱 클라이언트 앱 / Client Apps

| 플랫폼 | 다운로드 링크 |
|--------|--------------|
| Windows | [WireGuard for Windows](https://www.wireguard.com/install/) |
| macOS | [App Store](https://apps.apple.com/app/wireguard/id1451685025) |
| iOS | [App Store](https://apps.apple.com/app/wireguard/id1441195209) |
| Android | [Play Store](https://play.google.com/store/apps/details?id=com.wireguard.android) |
| Linux | `apt install wireguard` |

## 📖 상세 문서 / Documentation

- [한국어 상세 가이드](docs/README-ko.md)
- [클라이언트 설치 가이드](docs/CLIENT-SETUP.md)

## 🔒 보안 / Security

- ChaCha20 암호화
- Poly1305 인증
- Curve25519 키 교환
- 완전 순방향 비밀성 (PFS)

## 📄 라이선스 / License

MIT License