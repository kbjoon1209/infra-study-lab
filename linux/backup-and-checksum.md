# Backup and Checksum Validation

## 목적

Nginx 웹 콘텐츠와 설정 파일을 백업하고, 체크섬을 통해 백업 파일의 무결성을 확인한다.

## 백업 대상

| 대상 | 경로 | 설명 |
|---|---|---|
| 웹 콘텐츠 | `/var/www/html` | Nginx가 응답하는 HTML 파일 위치 |
| Nginx 설정 | `/etc/nginx/sites-available`, `/etc/nginx/sites-enabled` | 서버 블록 설정 및 활성화 링크 |

## 사용한 명령어

```bash
sudo tar -czf backups/day5/www-html-YYYYMMDD.tar.gz -C /var/www html
sudo tar -czf backups/day5/nginx-sites-YYYYMMDD.tar.gz -C /etc/nginx sites-available sites-enabled
sha256sum backups/day5/*-YYYYMMDD.tar.gz > backups/day5/SHA256SUMS-YYYYMMDD.txt
sha256sum -c backups/day5/SHA256SUMS-YYYYMMDD.txt
```

## 내가 이해한 내용

- 백업을 통해 nginx 웹 콘텐츠 html과 nginx 환경을 백업했다.
- 체크섬을 만들어 백업 파일이 손상되지 않았나 점검했다.
- 체크섬은 백업 파일의 지문을 남기는 작업이다.

## 한 문장 정리

- Nginx 웹 콘텐츠와 설정 파일을 tar로 백업하고, sha256sum 명령어로 무결성을 검증, 별도의 디렉토리를 만들어 테스트를 진행했다.