#AWS Rehost Migration Lab

## 프로젝트 목적

WSL Ubuntu에서 구축한 Nginx 원본 웹서비스를 AWS EC2 환경으로 수동 이관하는 Rehost 마이그레이션 시뮬레이션 프로젝트이다.

## 범위

- WSL Ubuntu 원본 Nginx 웹서비스 구축
- Linux 사용자, 권한, 서비스, 로그, 네트워크 점검 학습
- Packet Tracer를 통한 온프레미스 네트워크 구조 모사
- AWS VPC, Subnet, Route Table, Security Group, EC2 구성
- Nginx 콘텐츠 및 설정 파일 수동 이관
- 장애 시나리오 검증
- Bash 기반 상태 점검 자동화

## 주의

본 프로젝트는 실제 기업 시스템의 이전이 아니라 학습용 시뮬레이션이다.

## AWS 실습

- VPC 및 Public/Private Subnet 구성
- Internet Gateway와 Custom Route Table 구성
- Security Group 기반 SSH·HTTP 접근 제어
- EC2 Amazon Linux 2023과 Nginx 배포
- WSL Web Content의 EC2 Migration·Rollback
- AMI 기반 Private EC2 복제
- Security Group Reference를 이용한 내부 HTTP 통신
- Nginx 정상·장애·복구를 확인하는 Bash Health Check