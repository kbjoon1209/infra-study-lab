# AWS AMI and Private EC2 Internal HTTP Lab

## 목적

기존 Public EC2의 Nginx 환경으로 AMI를 생성하고,
AMI를 이용해 Public IPv4가 없는 Private EC2를 실행한다.

Public EC2의 Security Group을 Source로 지정하여
Public EC2에서 Private EC2의 Nginx로만 HTTP 통신할 수 있도록 구성한다.

---

## 전체 구조

```text
Internet
   │
Public EC2
10.10.1.0/24
Security Group: bj-web-sg
   │
   │ HTTP TCP 80
   ▼
Private EC2
10.10.2.0/24
Security Group: bj-private-web-sg
Public IPv4 없음
```

---

## AMI 생성

- Source Instance: bj-web-ec2
- AMI Name: bj-nginx-migration-ami
- AMI State: 사용 가능
- 포함된 Service: nginx
- 포함된 Web Content: index.html, health.txt
- EBS Snapshot: ami 생성 과정에서 만들어짐.

---

## Private Network 구성

| Resource | 설정 |
|---|---|
| Private Subnet | bj-private-subnet-a |
| CIDR | 10.10.2.0/24 |
| Auto-assign Public IPv4 | Disabled |
| Private Route Table | bj-private-rt |
| Route | 10.10.0.0/16 → local |

---

## Private Security Group

| Type | Protocol | Port | Source |
|---|---|---|---|
| HTTP | TCP | 80 | bj-web-sg |

- SSH Rule: 없음
- Internet 전체 HTTP Rule: 없음

---

## Private EC2

- Name: bj-private-web-ec2
- Source AMI: ami-0d5d6e86187d558f7
- Instance Type: t3.micro
- Private IPv4: 10.10.2.53
- Public IPv4: 없음
- Subnet: bj-private-subnet-a
- Security Group: bj-private-web-sg
- Status Check: 3/3 검사 통과

---

## 내부 HTTP 검증

- Public EC2 Source IP: 10.10.1.129
- Private EC2 Destination IP: 10.10.2.53
- `ip route get` 결과: 
 10.10.2.53 via 10.10.1.1 dev ens5 src 10.10.1.129 uid 1000
- HTTP `/`: HTTP/1.1 200 OK
- HTTP `/health.txt`: OK - migrated from WSL to AWS EC2
- 반환된 Page: 
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <title>WSL to AWS EC2 Migration Lab</title>
</head>
<body>
  <h1>WSL to AWS EC2 Migration Lab</h1>
  <p>Source: WSL Ubuntu</p>
  <p>Target: AWS EC2 Amazon Linux 2023</p>
  <p>Web Server: Nginx</p>
  <p>Deployment Status: Success</p>
</body>
</html>

---

## Security Group 장애 재현

### 정상 상태

- HTTP 결과: HTTP/1.1 200 OK

### Rule 제거

- 제거한 Rule: HTTP inbound rule
- HTTP 결과: (28) Connection timed out

### 복구

- 복구한 Rule: HTTP inbound rule
- HTTP 결과: HTTP/1.1 200 OK

---

## 내가 이해한 내용

- 기존에 생성한 EC2를 기반으로 AMI를 만들었다.

- 해당 AMI로 새 EC2 인스턴스를 생성했고 vpc 내부 통신용 local 루트만 사용하는 10.10.2.0/24를 private subnet에 배치했다.

- 새로운 ec2, 이하 private ec2는 게이트웨이 및 라우팅 테이블에 외부와 통신하는 경로가 존재하지 않으며, public ipv4도 존재하지 않으므로 현재 구성에서는 인터넷과 직접 통신은 불가능하다.

- 보안 그룹은 기존 ec2의 bj-web-sg를 소스로 http 트래픽만 허용하도록 했다.

- WSL2 우분투에서 기존 ec2로 ssh 연결 수립 후 private ec2와 정상 http 통신을 확인했다.

- 이후 private ec2 sg에서 http 인바운드 규칙을 제거하고 (28) connection timed out 에러를 확인했다.

- 다시 private ec2 sg에서 http 인바운드 규칙을 추가하고 정상 http 통신 확인 하였다.

## 오늘 헷갈린 점

- 내부와 통신하는 것이면 신규 sg은 만들 필요가 없지 않나 생각해서 따로 찾아봤는데 sg은 ec2마다 하나씩 붙어서 경호하는 경호원과 같기 때문에 외부와 통신하지 않는다고 해도 같은 VPC 내에 있는 public ec2가 해킹 당하는 경우와 같은 상황에 대비하기 위해 sg를 새로 구성한다고 한다.

- 