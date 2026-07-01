# 원본 웹 서버 (WSL Ubuntu) 빌드 및 검증 기록

본 문서는 AWS 이관(Migration)을 하기 전, 로컬 WSL 우분투 환경에 구축된 원본(Source) 웹 서버의 상태를 점검하고 기록한 검증 보고서이다.

---

## 1. Nginx 서비스 구동 상태 확인
- 목적: Nginx 웹 서버 프로세스가 메모리에 정상 상주하여 구동 중인지 확인
- 명령어: `systemctl status nginx`

```text
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-06-29 13:02:50 KST; 2h 29min ago
   Main PID: 200 (nginx)
      Tasks: 17 (limit: 18639)
     Memory: 13.3M (peak: 17.5M)
        CPU: 46ms
     CGroup: /system.slice/nginx.service
             ├─200 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             └─202~220 "nginx: worker process (총 16개 프로세스 구동 확인)"

Jun 29 13:02:50 KBJ-DESKTOP systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
Jun 29 13:02:50 KBJ-DESKTOP systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.
```

## 2. Nginx 설정 파일 문법 검사
- 목적: 웹 서버 설정파일에 오타나 구성 오류가 없나 사전 검증
- 명령어: 'sudo nginx -t'

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

## 3. 네트워크 Port 바인딩 확인
- 목적: Nginx가 외부 접속을 받기 위해 80번 포트를 정상적으로 Listen하고 있는지 확인

```text
- 명령어: ss -lntp
State     Recv-Q    Send-Q        Local Address:Port        Peer Address:Port   Process
LISTEN    0         511                 0.0.0.0:80               0.0.0.0:*
LISTEN    0         4096             127.0.0.54:53               0.0.0.0:*
LISTEN    0         1000         10.255.255.254:53               0.0.0.0:*
LISTEN    0         4096          127.0.0.53%lo:53               0.0.0.0:*
LISTEN    0         511               127.0.0.1:45829            0.0.0.0:*       users:(("MainThread",pid=564,fd=22))
LISTEN    0         511                    [::]:80                  [::]:*
```

## 4. 로컬 HTTP 통신 응답 검증
- 목적: 웹 서버 내부에서 실제 HTTP 요청에 대해 정상 응답을 뱉는지 가상 브라우저 테스트
- 명령어: curl -I http://localhost

```text
HTTP/1.1 200 OK
Server: nginx/1.28.3 (Ubuntu)
Date: Mon, 29 Jun 2026 06:33:30 GMT
Content-Type: text/html
Content-Length: 615
Connection: keep-alive
```

| 점검 항목 | 명령어 | 확인 결과 | 판정 |
|---|---|---|---|
| Nginx 서비스 상태 | `systemctl status nginx` | `active (running)` | 정상 |
| 설정 파일 문법 | `sudo nginx -t` | `syntax is ok`, `test is successful` | 정상 |
| 80번 포트 Listen | `ss -lntp` | `0.0.0.0:80`, `[::]:80` Listen | 정상 |
| HTTP 응답 | `curl -I http://localhost` | `HTTP/1.1 200 OK` | 정상 |
| Nginx 버전 | `nginx -v` | `nginx/1.28.3 (Ubuntu)` | 확인 완료 |
| 웹 콘텐츠 경로 | `ls -l /var/www/html` | `index.html` 확인 | 정상 |

## 5. 웹 콘텐츠 수정 및 응답 검증
- 목적: Nginx가 제공하는 기본 HTML 파일을 수정하고, HTTP 응답 및 로그 기록을 검증한다.
- 수정 파일: `/var/www/html/index.html`
- 백업 파일: `/var/www/html/index.html.bak`
- 검증 명령어:
  - `curl -I http://localhost`
  - `curl http://localhost`
  - `sudo tail -n 20 /var/log/nginx/access.log`
  - `sudo tail -n 20 /var/log/nginx/error.log`

### 검증 결과

| 항목 | 결과 | 판정 |
|---|---|---|
| HTML 파일 수정 | index.html 내용 변경 확인 | 정상 |
| HTTP 헤더 응답 | `HTTP/1.1 200 OK` | 정상 |
| HTTP 본문 응답 | 수정된 HTML 출력 확인 | 정상 |
| access.log | `GET / HTTP/1.1` 요청 기록 확인 | 정상 |
| error.log | 신규 오류 없음 | 정상 |

## 6. 파일 권한 변경에 따른 웹 접근 장애 검증

- 목적: Nginx가 서비스하는 HTML 파일의 권한이 HTTP 응답에 어떤 영향을 주는지 확인한다.
- 대상 파일: `/var/www/html/index.html`
- 정상 권한: `644`
- 장애 유발 권한: `600`

### 1) 정상 상태 확인

- 명령어:
  - `ls -l /var/www/html/index.html`
  - `curl -I http://localhost`

- 결과:
  - 파일 권한: `rw-r--r--`
  - HTTP 응답: `200 OK`

### 2) 장애 유발

- 명령어:
  - `sudo chmod 600 /var/www/html/index.html`
  - `curl -I http://localhost`

- 결과:
  - 파일 권한: `rw-------`
  - HTTP 응답: `403 Forbidden` 또는 접근 오류 발생

### 3) 로그 확인

- 명령어:
  - `sudo tail -n 20 /var/log/nginx/error.log`

- 확인 내용:
  - `permission denied` 관련 오류 확인

### 4) 복구

- 명령어:
  - `sudo chmod 644 /var/www/html/index.html`
  - `curl -I http://localhost`

- 결과:
  - HTTP 응답 `200 OK` 복구

### 정리

Nginx 서비스가 정상 실행 중이고 80번 포트가 열려 있어도, 웹 콘텐츠 파일 권한이 잘못 설정되면 HTTP 403 오류가 발생할 수 있다.  
따라서 웹서비스 장애 점검 시 서비스 상태, 포트 상태, HTTP 응답뿐 아니라 파일 권한과 error.log도 함께 확인해야 한다.