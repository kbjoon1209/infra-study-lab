# AWS Week 3 Operations Runbook

## 목적

AWS VPC와 EC2 Nginx 실습 환경의 시작, 상태 확인,
장애 범위 분리, 복구 및 종료 절차를 정리한다.

---

## 전체 구조

```text
Internet
   │
Internet Gateway
   │
Public Route Table
   │
Public EC2
   │ HTTP TCP 80
   │
Private EC2
```

---

## Resource Inventory

| Resource | Name | 상태 | 유지 여부 |
|---|---|---|---|
| VPC | bj-lab-vpc | Available | 유지 |
| Public Subnet | bj-public-subnet-a | Available | 유지 |
| Private Subnet | bj-private-subnet-a | Available | 유지 |
| Public EC2 | bj-web-ec2 | | 유지·Stop |
| Private EC2 | bj-private-web-ec2 | | Terminate |
| AMI | bj-nginx-migration-ami | | 정리 |
| Snapshot | 마스킹 | | 정리 |

---

## Public EC2 시작 절차

1. EC2 Instance를 Start한다.
2. Status Check 통과를 확인한다.
3. 새 Public IPv4를 확인한다.
4. SSH Source가 현재 내 Public IP인지 확인한다.
5. Nginx Service와 HTTP 응답을 검증한다.

---

## Health Check

```bash
./scripts/aws-web-healthcheck.sh <PUBLIC_EC2_IP>
```

### 정상 결과

- `/`: 성공
- `/health.txt`: 기대 문자열 일치
- Result: HEALTHY
- Exit Code: 0

### 실패 결과

- HTTP 요청 실패
- Result: UNHEALTHY
- Exit Code: 1

---

## 장애 점검 순서

| 증상 | 우선 확인 |
|---|---|
| SSH Timeout | Public IP, SSH SG Rule, Route, Instance State |
| SSH Public Key 오류 | Key 경로, Key Pair, Linux 사용자 |
| Local HTTP 실패 | Nginx Service, TCP 80, 설정, Log |
| Local HTTP 정상·External 실패 | Security Group, Public IP, Route |
| Public EC2→Private EC2 실패 | Private SG, Private IP, local Route |

---

## Nginx 복구 절차

```bash
systemctl is-active nginx
sudo ss -lntp | grep ':80'
sudo nginx -t
sudo journalctl -u nginx --since "-10 min" --no-pager
sudo systemctl restart nginx
curl -I http://localhost
```

---

## 종료 절차

1. Health Check 결과를 기록한다.
2. 필요한 Screenshot과 문서를 저장한다.
3. Public EC2를 Stop한다.
4. 불필요한 Private EC2를 Terminate한다.
5. 불필요한 AMI와 Snapshot을 삭제한다.
6. Billing과 실행 중 Resource를 확인한다.

---

## 내가 이해한 내용

- WSL2 ubuntu에서 AWS EC2의 http://localhost 검증을 간단하게 할 수 있는 스크립트를 지티피의 도움을 받아 만들었다.

- 기존에는 / -> /health 이런 식으로 별도의 명령어로 작업하던 것을 일괄적으로 묶어서 편하게 명령을 내렸고 http 1.1/ 200 OK라고 나오는 부분도 target ip -> 상태 -> 결과 순으로 알아보기 편했다.

- ec2 nginx 상태를 확인하고 스크립트로 http 검증을 하고 난 뒤 nginx 중단 후 http 검증 스크립트의 변화를 확인 후 다시 복구한 뒤 마지막으로 정상 작동을 확인했다.

## 오늘 헷갈린 점

- 스크립트가 추가된 점 외에는 따로 어려울 것은 없었다.

-