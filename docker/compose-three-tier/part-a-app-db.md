# Docker Compose App + MySQL Lab

## 목적

Docker Compose 환경에서 Python App과 MySQL DB를 구성하고,
Host에서 App로 HTTP 요청을 전달한 뒤 App가 별도의 DB 연결을 생성해
MySQL과 통신하는 구조를 확인한다.

또한 DB 연결 과정에서 발생한 장애를 App Log로 분석하고
Dependency 수정 및 Image 재빌드를 통해 복구한다.

## 구조

```text
Client / Host
↓ HTTP Request
localhost:5001
↓ Docker Port Mapping
App Container :5000
↓ /db-check 실행 시 별도의 DB 연결 생성
db:3306
↓
MySQL
```

## 내가 이해한 내용

- 클라이언트 -> APP -> DB로 이어지는 구조를 이해했다.
- 기존에는 클라이언트 -> Nginx -> APP(http server)로 이어지는 구조였지만 오늘은 DB라는 새로운 재료가 추가되었다.
- Docker Compose로 app과 db의 작동은 성공했고 app과 curl -i http://localhost:5051/health로 http 통신이 정상작동 하는 것을 확인했고, 이후에 /db-check로 db와 통신이 가는 것은 unreachble 에러가 뜨면서 실패했다.
- 원인을 찾기 위해 docker compose logs app --tail 20으로 cry?로 시작하는 MYSQL 인증에 필요한 도구가 누락된 것을 확인한 후 reqirement.txt에서 수정을 한 뒤 이미지를 다시 빌드해서 성공했다.

## 오늘 헷갈린 점

- 이전까지는 app/index.html or app/index.jsp // nginx/default.conf // 바깥에 compose.yaml 각각 웹컨텐츠 / 리버스프록시 역할 NGINX / COMPOSE 설계도 3덩이로 묶어서 쉽게 알 수 있었지만 이번에는 MYSQL이라는 DB가 추가되어서 많이 어려웠다.
- app.py의 코드도 어려웠으며 여태까지는 Custom Image 빌드할 때만 사용한 Dockerfile이 같이 쓰였다.
- requirement.txt는 db랑 app에 필요한 도구?를 정의하는 것인가? 의문이 들었다.
- .env는 db의 암호와 이름 등 계정을 담은 정보라고 이해하면 되는 것일까.
- compose.yaml은 기존에 암기한대로 db와 app을 연결하기 위해 사용했다고 이해했다.
- 오늘은 전반으로 새로운 개념이 많이 나와서 어려웠으며, 과제에서 주어진 주석에서 이것을 확인하면 된다라는 설명은 있지만 보아도 잘 이해하기 힘들었다.
- 왜 db가 3306 포트로 사용하는 지, 어디서 정의한 건지 봐도 알 수가 없었다.
- host 5001 -> app 5000? -> db 3306 이렇게 흘러가는 흐름인가?
- 172.~로 시작하는 db의 ip주소를 봤지만 여전히 개념이 헷갈린다.

## 한 문장 요약

- 도커 컴포즈로 APP과 MYSQL DB를 구성해서 /health와 /db-check로 app 상태와 db 연결 상태를 각각 검증했고, db 인증 과정에서 에러가 발생해서 app 로그로 검증 후, 이미지를 다시 빌드해 db 연결을 복구했다.