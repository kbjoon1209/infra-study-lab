# Nginx 설정 구조 확인

## 목적

Nginx가 어떤 설정을 기준으로 `/var/www/html/index.html` 파일을 서비스하는지 확인한다.

## 주요 설정 파일

| 경로 | 역할 |
|---|---|
| `/etc/nginx/nginx.conf` | Nginx 전체 기본 설정 |
| `/etc/nginx/sites-available/default` | 기본 서버 블록 설정 |
| `/etc/nginx/sites-enabled/default` | 활성화된 서버 블록 링크 |
| `/var/www/html` | 기본 웹 콘텐츠 경로 |
| `/var/log/nginx/access.log` | 접근 로그 |
| `/var/log/nginx/error.log` | 오류 로그 |

## 확인한 핵심 설정

| 설정 | 의미 |
|---|---|
| `listen 80` | HTTP 80번 포트에서 요청 수신 |
| `root /var/www/html` | 웹 콘텐츠 기본 경로 |
| `index index.html ...` | 기본 응답 파일 우선순위 |
| `server_name _` | 기본 서버 이름 처리 |

## 정리

Nginx는 `sites-enabled/default`에 활성화된 서버 블록 설정을 기준으로 80번 포트 요청을 받고, `root /var/www/html` 경로의 `index.html` 파일을 응답한다.