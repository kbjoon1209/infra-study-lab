# Docker Bind Mount Basic

## 목적

Host 디렉터리를 Nginx Container 내부 웹 콘텐츠 경로에 연결하고,
Image rebuild 없이 파일 변경이 반영되는지 확인한다.

## 구성

Host:
docker/bind-mount-nginx/html

↓

Bind Mount

↓

Container:
/usr/share/nginx/html

## 핵심 명령어

```bash
docker run --name week2-bind-nginx \
  -d \
  -p 8083:80 \
  -v "$(pwd)/html:/usr/share/nginx/html:ro" \
  nginx:alpine

docker exec week2-bind-nginx \
  cat /usr/share/nginx/html/index.html

docker inspect \
  --format '{{json .Mounts}}' \
  week2-bind-nginx
  ```

## 내가 이해한 내용

- 기존의 docker build 방식으로는 웹 컨텐츠 html 파일이 수정되었을 경우, 수정 후 이미지를 다시 build 해야 하는 불편함이 있었다.
- docker bind mount를 사용하는 경우에는 호스트 html 웹 컨텐츠 파일을 수정하면 컨테이너에 자동으로 반영된다.

## 오늘 헷갈린 점

- 오늘은 특별히 헷갈린 점은 없었지만 실제 명령어가 복잡하기 때문에 실제로 많이 사용해봐야 손에 익을 거 같다.

## 한 문장 정리

- docker bind mount를 이용하면 호스트로 지정한 index.html 파일 수정사항이 실제 실행 중인 docker의 컨테이너에 반영되기 때문에 이전과 같은 방식으로 실행했을 때처럼 index.html이 수정되면 docker image를 다시 빌드하고 run 할 필요가 없어졌다.