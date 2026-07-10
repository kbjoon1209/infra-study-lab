# MySQL Volume Persistence and Backup Restore Lab

## 목적

Docker Compose 환경에서 MySQL Data가 Named Volume에 저장되는 구조를 확인하고,
Container 제거 후에도 Data가 유지되는지 검증한다.

또한 mysqldump를 이용해 Database Backup File을 생성하고,
Test Table 삭제 후 Backup File을 이용한 Restore를 수행한다.

---

## 구조

```text
MySQL Container
↓
/var/lib/mysql
↓
Named Volume
compose-three-tier_db_data
```
## PART A 실습

## 내가 이해한 내용

- 오늘의 어제와 똑같이 Nginx - Python App - MySQL 구조를 그대로 사용해서 db의 데이터가 어디에 저장되고 컨테이너의 생명주기와 DB 볼륨의 생명주기가 같지 않다는 점을 실습했다.
- docker compose down으로 기존 컨테이너를 제거하고 다시 생성해서 MySQL 내부의 데이터가 정상적으로 남아있는 것을 확인했다.
- Volume은 컨테이너의 생명주기와 별도로 관리되는 저장 공간이라고 이해했다. 

## 오늘 헷갈린 점

- db_data:/var/lib/mysql의 구조가 헷갈렸다. HOST : 컨테이너 내부...의 구조라고 기억했던 거 같다. 바인트 마운트라고 1주차에 배웠던 내용이고 컨테이너 내부 경로와 특정 디렉토리를 연결하는 작업으로 기억하는데 순서가 기억이 나지 않는다.

## 한 문장 요약

- DB 컨테이너의 생명주기와 Volume의 생명주기는 일치하지 않으며, 컨테이너를 제거하고 다시 생성해도 별도의 명령으로 삭제되지 않는 한 데이터는 유지된다.

## PART B 실습

## 내가 이해한 내용

- MySQL DB 내부 자료를 백업하고 체크섬 검증을 한 뒤, DB 테이블을 고의로 삭제 후 완전히 삭제가 되었는 지 확인한 후에 백업본으로 복구 작업을 수행했다.
- 이전에 Nginx 내부 환경 디렉토리 및 웹 컨텐츠 파일을 .tar.gz로 백업한 후 sha256 체크섬 검증한 뒤 복구한 적이 있는데 그 작업과 흐름은 유사하다고 깨달았다. 

## 오늘 헷갈린 점

- 이전에 실습했던 nginx 백업 후 체크섬 검증과 진행과정은 비슷했기 때문에 어려운 점은 없었다.
- nginx는 복수의 데이터를 압축 후 백업한 뒤 체크섬 검증했지만 이번에는 단일 파일 1개만 백업했기 때문에 크게 막히는 부분은 없었지만 여전히 명령어에 대한 이해는 복습이 필요할 거 같다.

## 한 문장 요약

- MySQL의 DB 데이터는 실제 db 컨테이너 내부에서 dump 명령어를 수행해서 sql 형태로 출력한 것을 host로 저장한 후, 테이블 삭제 후 다시 MySQL 컨테이너 내부에서 데이터 복구를 검증했다.