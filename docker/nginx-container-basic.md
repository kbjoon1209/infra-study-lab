# Docker Nginx Container Basic

## 목적

Docker 컨테이너로 Nginx를 실행하고, 호스트 포트와 컨테이너 포트의 매핑을 확인한다.

## 실행 명령어

```bash
docker run --name day5-nginx -d -p 8080:80 nginx:alpine
```

## 내가 이해한 내용

- Docker는 OS와 커널을 공유하면서, 서비스/애플리케이션 실행에 필요한 라이브러리만 격리된 컨테이너 공간에 패키징하는 기술이다.
- Docker는 가상 VMware과는 다르다.

## 오늘 헷갈린 점

- Docker와 가상 VM ware의 차이가 헷갈렸다.
- 이미지와 컨테이너의 차이가 아직 헷갈린다.

## 한 문장 요약

- Nginx를 OS에 직접 설치하는 방식과 Docker 컨테이너로 실행하는 방식을 비교했고, 포트 매핑을 통해 컨테이너 내부 80번 포트를 호스트의 8080번 포트로 노출함.