# Korea Payment (한국 결제 시스템)

한국 결제 게이트웨이를 위한 Node.js 결제 처리 애플리케이션입니다.

## 주요 기능

- 다양한 한국 결제 게이트웨이 지원
  - KG이니시스 (inicis)
  - KG모빌리언스 (kg)
  - NICE페이먼츠 (nice)
  - 토스페이먼츠 (toss)
  - 카카오페이 (kakao)
- 결제 초기화, 처리, 상태 조회, 취소 기능
- RESTful API 제공

## 설치

```bash
npm install
```

## 실행

```bash
npm start
```

서버가 기본적으로 3000 포트에서 실행됩니다.

## API 엔드포인트

| 메소드 | 경로 | 설명 |
|--------|------|------|
| GET | `/health` | 서버 상태 확인 |
| GET | `/api/gateways` | 지원되는 결제 게이트웨이 목록 |
| POST | `/api/payment/initialize` | 결제 초기화 |
| POST | `/api/payment/process` | 결제 처리 |
| GET | `/api/payment/status/:transactionId` | 거래 상태 조회 |
| POST | `/api/payment/cancel` | 결제 취소 |

## 사용 예시

### 결제 초기화

```bash
curl -X POST http://localhost:3000/api/payment/initialize \
  -H "Content-Type: application/json" \
  -d '{
    "gateway": "toss",
    "amount": 10000,
    "productName": "테스트 상품",
    "customerName": "홍길동"
  }'
```

### 결제 처리

```bash
curl -X POST http://localhost:3000/api/payment/process \
  -H "Content-Type: application/json" \
  -d '{
    "transactionId": "YOUR_TRANSACTION_ID"
  }'
```

### 거래 상태 조회

```bash
curl http://localhost:3000/api/payment/status/YOUR_TRANSACTION_ID
```

## 테스트

```bash
npm test
```

## 환경 변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `PORT` | `3000` | 서버 포트 |

## 라이센스

ISC