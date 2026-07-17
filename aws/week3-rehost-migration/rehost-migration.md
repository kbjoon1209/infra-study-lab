# WSL to AWS EC2 Nginx Rehost Migration

## 목적

WSL에서 준비한 정적 웹 콘텐츠를 tar.gz로 압축하고
SHA256 Checksum으로 무결성을 검증한 뒤,
SCP를 이용해 AWS EC2로 전송하고 Nginx에 배포한다.

---

## 전체 흐름

```text
WSL Source
↓
tar.gz
↓
SHA256 검증
↓
SCP
↓
EC2 수신 검증
↓
기존 Web Root Backup
↓
Staging 확인
↓
Nginx 배포
↓
Local / External HTTP 검증
```

---

## EC2 Stop/Start 확인

- Instance State: 실행 중
- Status Check: 정상
- Private IPv4 유지 여부: 유지됨
- Public IPv4 변경 여부: 변경됨
- Nginx 자동 시작: 자동 시작됨
- 기존 index.html 유지: 유지됨

---

## Source 구성

| File | 역할 |
|---|---|
| index.html | 이전할 정적 웹페이지 |
| health.txt | 배포 상태 확인 |

---

## Package 생성

- Archive: source-site-20260716.tar.gz
- Archive 내용: index.html, health.txt
- Local SHA256 결과: OK

---

## SCP 전송

- Source: WSL의 migration/artifacts/
- Destination: EC2의 /home/ec2-user/
- EC2 수신 파일: source-site-20260716.tar.gz, source-site-20260716.tar.gz.sha256
- EC2 SHA256 결과: OK

---

## 배포 전 Backup

- Backup File: nginx_html-before_migration-20260715-163258.tar.gz
- Backup 내용: 기존 index.html, 400.html, 50x.html, 이미지 및 아이콘
- Backup Checksum: ok

---

## Staging 검증

- index.html: 316 bytes, 정상
- health.txt: 34 bytes, 정상
- 검증 결과: 배포 대상 파일의 존재 여부와 내용을 확인함.

---

## Nginx 배포 결과

- Service 상태: 정상
- TCP 80 Listener: 정상
- Local `/`: http 200 정상
- Local `/health.txt`: 정상
- External `/`: http 200 정상
- External `/health.txt`: 정상
- Access Log: local 및 외부 요청 http 200 기록 확인

---

## Rollback 검증

- 수행 여부: 수행함.
- 이전 버전 복구 결과: 복구 정상
- 새 버전 재배포 결과: 재배포 정상

---

## 내가 이해한 내용

- WSL2 우분투에서 만든 index.html과 health.txt를 tar로 묶어서 무결성 검증 후 SCP 명령으로 AWS EC2로 전송했다.
- EC2에서 수신한 파일을 다시 체크섬으로 검증하고 별도의 staging 디렉토리에 압축을 풀어 내용물을 확인해서 배포했다.
- 기존 EC2 Nginx 웹 컨텐츠 파일은 별도로 백업해두었다.
- 롤백 과정에서 위의 백업 파일을 복원하고 health.txt를 제거하여 이전 페이지가 다시 표시되는 걸 확인했다.
- 마지막으로 WSL2에서 가져온 index.html 파일을 다시 배포하여 복구했다.
- 전체 과정은 WSL2의 컨텐츠를 EC2 환경으로 옮기는 것을 마이그레이션, 검증한 파일을 실제 서비스에 반영하는 것이 배포라고 이해했다.

## 오늘 헷갈린 점

- 어려운 명령어가 많아서 오타가 많이 나왔다든 점 외에는 흐름 자체가 어려운 점은 없었다.
