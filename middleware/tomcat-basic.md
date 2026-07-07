# Tomcat Basic Operations

## 목적

Docker 환경에서 Tomcat을 실행하고,
최소 JSP Web Application을 배포해
HTTP 응답, Java Runtime, Process, Log를 확인한다.

## 구성

```text
Client
  ↓
localhost:8085
  ↓
Tomcat Container :8080
  ↓
ROOT/index.jsp
```

## 내가 이해한 내용

- 이전까지는 index.html이라는 파일을 사용했지만 오늘은 index. jsp 파일은 먼저 만든 뒤에 tomcat이라는 이미지를 이용해 컨테이너를 실행했다.
- 이전까지는 정적 html 컨텐츠 문서를 화면에 출력했지만 오늘은 JSP라는 형식의 파일을 서버측에서 처리한 결과를 받았다.
- HTML은 정적 웹페이지를 설계하는 MARK-UP 언어지만 JSP는 JAVA 기반 웹 기술로, 서버에서 동적 HTML 응답을 생성하는 데 사용할 수 있다고 한다.
- 실제로 오늘은 JSP 파일을 구성할 때 시간을 출력하도록 설계했고 웹 컨텐츠를 curl 도구로 호출했을 때 시간이 요청 시점의 시간으로 변하는 것을 확인했다.

## 오늘 헷갈린 점

- 오늘은 단순히 tomcat 이미지를 받아서 컨테이너를 실행한 뒤 로그만 확인하는 정도라서 어려운 점은 없었지만, docker exec로 도커에 직접 명령을 내려서 txt 파일을 확인했는데 nginx에 비해서 좀 복합한 거 같다.
- 이전에 nginx는 80번 포트로 연결했었지만 tomcat은 8080 포트로 연결했는데 차이가 뭔지 모르겠다.
- 이미 정의된 포트 외에는 어디까지 사용이 가능한 지 궁금증이 들었다. 예를 들어 16000번 포트나 343434포트 이런 것도 가능한가 의문이 생겼다.

## 한 문장 요약

- index.jsp로 tomcat 내부 컨텐츠 파일을 정의해서 HOST 8085 포트가 tomcat 8080포트로 매핑되도록 구성했고 이전까지는 정적이었던 index.html 파일이 아닌, 요청할 때마다 시간이 변하는 index.jsp 파일을 구성해서 실습했다.