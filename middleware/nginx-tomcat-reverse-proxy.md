# Nginx to Tomcat Reverse Proxy

## 목적

Docker Compose 환경에서
Nginx web Service와 Tomcat app Service를 구성하고,
Reverse Proxy를 통해 JSP Web Application에 요청을 전달한다.

## 구조

```text
Client
  ↓
localhost:8086
  ↓
Nginx web:80
  ↓
proxy_pass
  ↓
Tomcat app:8080
  ↓
ROOT/index.jsp
```

## 장애 시나리오

Tomcat Stop
  ↓
Nginx Upstream Connection Failure
  ↓
502 Bad Gateway
  ↓
Nginx Log 확인
  ↓
Tomcat Start
  ↓
200 OK 복구

## 내가 이해한 내용

- 과거 실습했던 클라이언트 -> Nginx -> Python HTTP server과 마찬가지로 이번에는 클라이언트 -> Nginx -> Tomcat으로 넘어가는 흐름을 이해했다.
- HOST 8086 포트와 Nginx 80포트를 매핑하도록 compose.yaml에서 정의했으며, nginx 내부 디렉토리에 default.cof에 리버스 프록시를 구성해 http://app:8080과 같이 service name으로 수신을 넘겼다.
- 처음에는 낯설었지만 2번째 실습의 경우 백엔드 서비스(index.jsp or index.html) / nginx (defalut.conf) / compose.yaml로 나눠서 이해하니까 한결 쉬웠다.

## 오늘 헷갈린 점

- 과거 정보처리기사에서 암기했던 WAS, 웹 어플리케이션 서버를 직접 눈으로 봤는데 WAS -> 동적 웹 컨텐츠 제공 정도로 인식하고 있어서 단순히 동적 웹 컨텐츠를 제공하기 위해서 .JSP 파일을 사용하는가? 라는 의문이 들었다.
- 자격증을 공부하면서 IP주소는 나의 집주소(논리적 주소), MAC 주소는 실제 물리적 주소, 포트는 내 방문/창문으로 외웠었다.
- localhost는 외부 인터넷과 아예 통신하지 않고 단순히 내부로만 동작하는 것인가? 하는 의문이 들었다. 
- curl -I http://localhost:8086 명령을 내리면 내 집의 8086번 방문으로 들어가서, 집주인과 집을 공유하는 Nginx 라는 작은 컨테이너의 80번 입구로 진입 후, 외부에서는 들어갈 수 없는 Tomcat의 컨테이너의 지하실 8080문으로(NGINX 컨테이너와 지하로 연결) 들어가서 JSP 파일을 처리 후 클라이언트에 반환하는 구조...라고 단순화 해서 이해하고 있는데 여전히 명확하지 않고 헷갈린다.

## 한 문장 요약
- Nginx 컨테이너, Tomcat 컨테이너 2개를 compose 환경으로 일괄 정의하고 Nginx 디렉토리 내부에 conf로 리버스 프록시 설정 작업을 했고 클라이언트 -> Nginx -> Tomcat 서비스의 index.jsp 으로 넘어가는 흐름과 tomcat 백엔드 서비스를 강제로 중지 시킨 뒤, 어떠한 오류가 발생했는 지 확인하고 502 bad gateway 오류를 docker compose 내부에서 서비스간 통신과 Nginx 로그를 검증한 뒤 장애를 복구했다.