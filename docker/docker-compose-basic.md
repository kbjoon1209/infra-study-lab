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
- docker compose는 여러개의 docker를 한 번에 build하고 관리할 때 사용한다.
- compose.yaml이라는 설계도를 이용해 생성할 수 있으며, 이전에 실습한 커스텀 docker image를 만들 때와 같이 Dockerfile이랑 index.html 파일이 필요하다.

## 오늘 헷갈린 점
- docker compose는 여러개의 도커를 생성하고 관리할 때 사용한다고 해서 쿠버네이트와 무슨 차이가 있나 헷갈렸지만 비유를 하면 docker compose는 프랜차이즈 매장 1개의 주방장/점장과 같다고 보면 되고 쿠버네이트는 프랜차이즈를 총괄해서 관리하는 매니저와 같다고 한다.

## 한 문장 요약
- docker compose는 여러개의 docker를 묶어서 빌드하고 관리할 수 있으며, 먼저 .yaml로 끝나는 설계도 파일과 Dockerfile, index.html파일을 필요로 하며, 별개의 명령어로 동작한다.
