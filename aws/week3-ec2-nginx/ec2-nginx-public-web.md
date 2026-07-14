# AWS EC2 Nginx Public Web Lab

## 목적

Public Subnet에 EC2를 생성하고 SSH로 접속한 뒤,
Nginx를 설치하여 외부 HTTP 통신을 검증한다.

또한 Nginx Service 중지와 Security Group HTTP 차단을 각각 재현하여
Service 장애와 AWS 접근 정책 장애를 구분한다.

---

## 전체 구조

```text
Internet
   │
Internet Gateway
   │
Public Route Table
0.0.0.0/0 → IGW
   │
Public Subnet
10.10.1.0/24
   │
Security Group
SSH 22 / HTTP 80
   │
EC2
Amazon Linux 2023
   │
Nginx TCP 80
```

---

## Resource 구성

| Resource | 설정 |
|---|---|
| EC2 Name | bj-web-ec2 |
| AMI | Amazon Linux 2023 |
| Instance Type | t3.micro |
| VPC | bj-lab-vpc |
| Subnet | bj-public-subnet-a |
| Security Group | bj-web-sg |
| Private IPv4 | 마스킹 |
| Public IPv4 | 마스킹 |

---

## EC2 상태 확인

- Instance State: Running
- Status Check: 2/2 checks passed
- Linux User: ec2-user
- OS: Amazon Linux 2023
- Kernel: 6.18.36-69.138.amzn2023.x86_64
- Private IPv4: 마스킹
- Default Route: default via 10.10.1.1 dev ens5

---

## Nginx 설치 및 검증

- Service 상태: active (running), enabled
- 설정 문법 검사: syntax is ok / test is successful
- Listening Port: TCP 80, 0.0.0.0:80 및 [::]:80
- Local HTTP 응답: HTTP 200
- External HTTP 응답: HTTP 200
- Document Root: /usr/share/nginx/html

---

## 장애 시나리오 1 — Nginx Service 중지

### 재현

- EC2 ssh bash에서 systemctl stop nginx로 nginx를 중지시키는 상황을 만들었다.

### 확인 결과

- Service: inactive
- TCP 80 Listener: 없음
- Local HTTP: 실패
- External HTTP: 실패
- Journal: Nginx Service 중지 및 정상 비활성화 기록 확인

### 복구

- 외부 통신 불가 -> 내부 통신 불가 -> 서비스 상태 및 포트 확인 -> 복구

- systemctl start nginx로 다시 실행 후 active 상태와 포트를 확인한 뒤 내부 통신과 외부 통신 정상을 검증했다.

---

## 장애 시나리오 2 — Security Group HTTP 차단

### 재현

- Security Group에서 인바운드 규칙 HTTP를 삭제해서 외부에서 통신이 되지 않는 상황을 가정했다.

### 확인 결과

- Nginx Service: active
- TCP 80 Listener: 있음
- Local HTTP: HTTP 200
- External HTTP: Timeout

### 복구

- 외부 통신 불가 -> 내부 통신 정상(HTTP200) -> 서비스 상태 및 포트 정상 -> EC2 내부 또는 nginx 문제는 아니었고 http 인바운드 규칙을 다시 생성해 외부 통신 정상을 검증했다.

---

## 장애 비교

| 점검 항목 | Nginx 중지 | Security Group 차단 |
|---|---|---|
| Service 상태 | inactive | active |
| TCP 80 Listener | 없음 | 존재 |
| Local HTTP | 실패 | 200 |
| External HTTP | 실패 | Timeout |
| 장애 영역 | EC2 내부 Service | AWS Inbound 접근 정책 |

---

## 내가 이해한 내용

- 겉으로 보기에는 같은 외부 통신 오류지만 원인은 nginx 서비스가 중단됐거나 Security Group 인바운드 규칙 문제로 발생했다.

- 외부 통신 에러가 발생하면 먼저 EC2 내부에 문제가 없나 점검하는 것이 먼저라고 이해했다.

- 기존의 실습했던대로 내부 통신 점검 -> 서비스 상태 및 포트 점검 -> 필요하면 로그 확인 후 복구 및 검증하는 과정을 이해했다.

## 오늘 헷갈린 점

- EC2에 VPC를 연결하는 과정 외에는 기존의 리눅스 실습에서 외부 통신이 추가된 과정이었기 때문에 특별히 어려운 점은 없었다.

-