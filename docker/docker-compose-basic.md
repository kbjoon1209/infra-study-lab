# Docker Compose Basic

## 목적

Dockerfile 기반 Custom Nginx 서비스를 `compose.yaml` 파일로 정의하고 실행한다.

## 구성

```text
compose.yaml
  ↓
Docker Compose
  ↓
Custom Nginx Build
  ↓
day6-compose-nginx
  ↓
localhost:8082
````

## 명령어

docker compose config
docker compose up -d --build
docker compose ps
docker compose logs --tail 20
docker compose down

## 내가 이해한 내용
- docker compose는 하나 이상의 컨테이너 서비스를 일괄적으로 생성, 실행, 중지, 관리할 수 있는 도구이다.
- compose.yaml이라는 파일을 이용해 정의하며, 기존 이미지를 그대로 사용해도 되지만 오늘 실습에서는 nginx 커스텀 이미지를 만들기 위해서, Dockerfile이랑 index.html 파일을 사용해 8082:80 포트 매핑까지 정의했다.

## 오늘 헷갈린 점
- docker compose는 여러개의 도커를 생성하고 관리할 때 사용한다고 해서 쿠버네이트와 무슨 차이가 있나 헷갈렸지만 비유를 하면 docker compose는 프랜차이즈 매장 1개의 주방장/점장과 같다고 보면 되고 쿠버네이트는 프랜차이즈를 총괄해서 관리하는 매니저와 같다고 한다. 상세한 정의는 확인했지만 나중에 쿠버네이트를 학습을 위해 흐름만 기억해둔다.

## 한 문장 요약
- docker compose는 compose.yaml 파일에 하나 이상의 컨테이너 서비스를 정의하고, docker compose 명령어로 일괄 관리할 수 있다.
