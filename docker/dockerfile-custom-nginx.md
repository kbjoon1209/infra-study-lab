# Dockerfile Custom Nginx Image

## 목적

기존 `nginx:alpine` 이미지를 기반으로 직접 작성한 `index.html`을 포함하는 Custom Docker Image를 생성한다.

## 구성

```text
nginx:alpine
  +
custom index.html
  ↓
Dockerfile
  ↓
bj-nginx:day6 image
  ↓
day6-custom-nginx container

## 사용한 명령어

docker build -t bj-nginx:day6 .
docker run --name day6-custom-nginx -d -p 8081:80 bj-nginx:day6
docker ps
curl http://localhost:8081
docker log day6-custom-nginx --tail 20

## 내가 이해한 내용

- 어제는 존재하는 nginx:alpine 이미지를 그대로 도커에 실행했지만 오늘은 nginx:alpine을 기반으로 Dockerfile과 html 컨텐츠 파일을 이용해서, 도커에 사용할 이미지를 만들었다.
- 완전히 처음부터 만든 것이 아닌, 이미 존재하는 nginx:alpine(FROM) 이미지를 기반으로 해서 docker build 명령 실행 시 내가 수정한 nginx 웹 컨텐츠 HTML(COPY)을 /usr/share/nginx/html/index.html 이곳에 복사하고, 이 서비스는 80번 포트를 사용한다고 정의한다.(EXPOSE)

# 한 줄 요약

- 커스텀 nginx 파일을 만들기 위해서는 html과 dockerfile을 준비해야 하고, docker build로 이미지를 생성한 뒤, docker run으로 해당 이미지를 컨테이너에 실행할 수 있다.

# 오늘 헷갈린 점

- docker image의 경로가 왜 /usr/share/nginx/html인지 고민했지만 실습해서 사용한 nginx:alpine의 경로가 그곳이었다. 이미지를 생성할 때 사용한 html 파일이 언제 이동하는 지 헷갈렸다.