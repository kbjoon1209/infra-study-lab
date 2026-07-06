# Docker Compose Two-Service Reverse Proxy

## 목적

Docker Compose에서 Nginx web 서비스와 Python app 서비스를 실행하고,
Nginx Reverse Proxy를 통해 app 서비스에 요청을 전달한다.

## 구조

```text
Client
  ↓
localhost:8084
  ↓
web:80
Nginx
  ↓
proxy_pass
  ↓
app:8000
Python HTTP Server
```

## 명령어

docker compose config
docker compose up -d
docker compose ps
curl http://localhost:8084
docker compose logs --tail 30
docker compose down

## 내가 이해한 내용
- 앱 1개와 웹서비스 1개를 compose로 정의하고 두 컨테이너 서비스를 같은 compose 환경에서 실행했다.
- 클라이언트 요청 -> 8084 -> nginx 내부 80 -> python 앱 8000으로 연결된다고 이해했다.
- 실제로 요청을 8084로 전달하면 app에 있는 html을 정상적으로 로딩하는 지 점검했고 정상적으로 요청이 수신된 것을 확인했다.
- Proxy라는 개념은 자격증 공부를 하면서 "대리인"이라는 개념으로 암기했었다.
- 찾아본 결과, 클라이언트의 정보은닉(대리)을 위한 프록시와 오늘 내가 사용한 서버를 은닉(대리)하기 위한 리버스 프록시라는 개념이 있었다.
- 리버스 프록시는 db, 실제 웹 컨텐츠 파일 등을 클라이언트에 직접 노출하지 않는다.
- 리버스 프록시는 보안, 로드밸런싱 등의 목적으로 사용하며 proxy_pass라는 conf 파일을 nginx 디렉토리 내부에 정의했다.

## 오늘 헷갈린 점
- python의 app 디렉토리에는 index.html을 넣어서 수정하는 작업을 했는데 이건 이전과 같아서 어렵지 않았지만, 이후에 nginx에 default.conf로 proxy_pass를 정의하고, 다시 compose.yaml 작업을 정의하는 것은 실제 실습 중에는 어려웠다.
- 실습 후에 다시 한 번 정리하면서 python app / nginx / compose.yaml를 별도로 묶어서 생각했더니 한결 수월했다. 
- app 내부의 index.html은 실제 파일, nginx는 겉에서 통신을 받아 넘겨주는 역할, 마지막으로 compose는 위 2개의 서비스를 일괄적으로 연결, 관리, 실행하게 해주는 도구라고 이해했다.
- 일부 명령어를 제외하고는 어렵지 않았으나 ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro와 같이 실제 호스트 경로 : 웹 서비스or컨테이너 내부 경로와 매핑 시키는 건 아직도 어려우며 ai나 구글링 없이는 수행하기 힘들 거 같다.

# 한 문장 요약
- 내가 오늘 배운 건 3-tier 구조로 나아가기 전 단계이며, 클라이언트 - 웹 서비스 - 파이썬 http server 구조로 외부의 요청을 nginx(웹 sw)가 받아서 파이썬 http으로 넘겨준다는 것이다.