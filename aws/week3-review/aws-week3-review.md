# AWS Week 3 Review

## Network 구조

```text
VPC: 10.10.0.0/16
Public Subnet: 10.10.1.0/24
Private Subnet: 10.10.2.0/24

Public Route: 0.0.0.0/0 -> Internet Gateway
Private Route: 10.10.0.0/16 -> local

Public EC2: 10.10.1.***
Private EC2: 10.10.2.***
```

## Resource 역할

| Resource | 내가 이해한 역할 |
|---|---|
| VPC | AWS에서 구축한 가상네트워크 공간 |
| Subnet | VPC라는 네트워크 공간을 유지관리 목적으로 나눈 것 |
| Route Table | 네트워크의 경로 설정하는 테이블 |
| Internet Gateway | 외부 인터넷과 VPC 사이의 연결 지점 |
| Security Group | EC2의 가상 방화벽과 같은 역할로 트래픽 허용/차단을 담당 |
| EC2 | AWS에서 임대해준 컴퓨팅 자원, 하나의 가상 컴퓨터 |
| AMI | 새로운 EC2 생성에 필요한 이미지 |
| EBS Snapshot | 특정 시점의 EBS Volume을 저장한 복사본 |

## 장애 구분

| 증상 | 의심 영역 |
|---|---|
| Nginx inactive, TCP 80 Listener 없음 | nginx 서비스 중단 의심 |
| Local HTTP 200, External HTTP Timeout | SG, IGW, ROUTING 등 의심 |
| Public EC2에서 Private EC2 HTTP Timeout | SG, ROUTING 의심 |
| SSH `Permission denied (publickey)` | 잘못된 키 사용 |
| SSH `Could not resolve hostname` | SSH 연결 시 잘못된 host ip 입력 |

## 이번 주에 직접 한 작업

- VPC를 생성해서 IGW, ROUTING TABLE, SUBNET, SG까지 설정해서 하나의 간단한 네트워크 리소스를 구축했다.

- Public subnet, Private Subnet을 만들어서 외부와 통신하는 EC2, 내부에서만 사용하는 EC2를 각각 연결해서 sg을 설정 후 통신을 점검했다.

- 처음 만든 EC2 instance를 AMI로 만들어서 스냅샷에 남긴 뒤 해당 AMI로 새로운 EC2 instance를 만들었다.

- 내 pc의 local WSL2 Ubuntu의 Nginx 컨텐츠 파일(health.txt 등)을 압축해서 체크섬 검증 후 AWS EC2로 scp 전송을 수행하고 똑같이 체크섬 검증 및 임시 디렉토리에 압축을 풀어 검증하고 배포까지 수행했다.

## 아직 혼자 하기 어려운 부분

- 기초적인 명령어 부분은 익혔지만 복잡한 명령어 같은 작업은 어렵다.

- VPC도 간단한 흐름은 잡았지만 서브넷-라우팅 테이블 연결 등 세부적인 작업은 혼자서 진행하려면 몇 번 반복하는 과정이 필요할 것 같다.

- CLI 환경에 어느정도 적응했지만 로그 같은 경우 영어와 숫자가 너무 많아서 핵심 부분만 빠르게 파악하는 능력은 아직 부족하다고 생각한다.