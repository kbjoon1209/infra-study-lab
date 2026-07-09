# Part B - Nginx App MySQL Three-Service Lab

## 목적

Nginx, Python App, MySQL을 Compose 환경으로 구성하고
DB 장애와 복구 흐름을 검증한다.

## 구조

```text
Client
↓
Host :8087
↓
Nginx :80
↓
app:5000
↓
db:3306
MySQL
```

## 내가 이해한 내용

- 파트 A에서 구성했던 클라이언트 요청 -> APP -> DB의 구조에서 리버스 프록시 역할을 담당하는 Nginx를 추가해서 Nginx -> APP -> DB의 구조를 만들었다.
- 이전에 실습했던 Tomcat를 고의로 중지한 장애 발생에서는 Nginx가 백엔드 서비스인 tomcat과 연결하지 못해 Upstream error를 확인했지만, 이번 db 장애에서는 Nginx와 APP사이 통신은 정상이었기 때문에 Nginx 로그에서는 app가 반환한 503 응답이 기록됐다.
- nginx 컨테이너 내부에서 직접 app에 명령을 보내서 Nginx와 app이 정상통신 중임을 확인했다.

## 오늘 헷갈린 점

- 파트 A 실습에서 이미 헷갈린 점이 많았지만 파트 B 실습에서는 단순히 Nginx만 추가해서 실습한거라서 이것은 기존의 구조랑 크게 달라서 어려운 점은 없었다.

## 한 문장 요약

- DB를 고의로 중지하면 Nginx와 app 사이 통신은 정상적으로 유지되서 /health에서는 정상적인 200을 반환했지만, app과 db 연결을 확인하는 /db-check에서는 503을 반환했으며 app log에서 실제 원인을 확인 후 복구했다.