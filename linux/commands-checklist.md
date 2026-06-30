# Linux / Nginx 점검 명령어 체크리스트

## `systemctl status nginx`

- 목적: Nginx 서비스 실행 상태 확인
- 정상 기준: `active (running)`
- 장애 기준: `inactive`, `failed`

## `sudo nginx -t`

- 목적: Nginx 설정 파일 문법 검사
- 정상 기준: `syntax is ok`, `test is successful`
- 실무 의미: 설정 반영 전 오류를 사전에 확인

## `ss -lntp`

- 목적: 서버가 어떤 TCP 포트에서 요청을 기다리는지 확인
- 정상 기준: Nginx가 `0.0.0.0:80` 또는 `[::]:80`에서 Listen