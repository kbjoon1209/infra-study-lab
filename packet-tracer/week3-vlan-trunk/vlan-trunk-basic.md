# Packet Tracer VLAN 10/20 and Trunk Lab

## 목적

하나의 물리 Switch Network를 VLAN 10과 VLAN 20으로 분리하고,
두 Switch 사이에 Trunk를 구성하여 같은 VLAN의 Traffic을 전달한다.

---

## 토폴로지

```text
PC1 VLAN 10 ─ S1 ═══ Trunk ═══ S2 ─ PC3 VLAN 10
PC2 VLAN 20 ─ S1 ═══ Trunk ═══ S2 ─ PC4 VLAN 20
```

---

## IP 및 VLAN 구성

| PC | IP | VLAN | 연결 Port |
|---|---|---|---|
| PC1 | 192.168.10.11/24 | 10 | S1 Fa0/1 |
| PC2 | 192.168.20.11/24 | 20 | S1 Fa0/2 |
| PC3 | 192.168.10.12/24 | 10 | S2 Fa0/1 |
| PC4 | 192.168.20.12/24 | 20 | S2 Fa0/2 |

---

## Switch 구성

- VLAN 10: USER_A
- VLAN 20: USER_B
- Access Port:
  - Fa0/1 → VLAN 10
  - Fa0/2 → VLAN 20
- Trunk Port:
  - Fa0/24
  - Allowed VLAN: 10,20

---

## 정상 통신 검증

- PC1 → PC3: 정상
- PC2 → PC4: 정상
- PC1 → PC2: timeout
- PC1 → PC4: timeout

---

## Trunk 장애 재현

- 변경 설정: S1에서 VLAN 허용 목록에 20을 제거
- VLAN 10 결과: pc1에서 pc3 ping 정상 vlan 정상
- VLAN 20 결과: pc2에서 pc4 ping timeout 오류 발생, vlan 비정상
- 장애 원인: S1에서 trunk 허용 목록에서 20이 누락되어 s1-s2 사이로 vlan 20 프레임이 통과하지 못함.

---

## 복구

- 복구 설정: S1에서 trunk 허용 목록에 VLAN 10, 20을 설정함.
- VLAN 20 통신 결과: 복구 후 PC2에서 PC4까지의 PING 성공

---

## 내가 이해한 내용

- VLAN은 하나의 물리적 네트워크를 여러개의 논리적 네트워크로 분리해서 부서별, 용도별로 나눠서 사용하는 것이라고 이해했다.

- 예를 들어 A팀 장비 10대, B팀 장비 30대, C팀 장비 5대가 있다고 가정하고 24포트 스위치 필요하다고 가정하면, VLAN을 사용하지 않으면 총 4대의 스위치 장비가 필요하지만 VLAN을 사용하면 2대의 스위치만으로도 구성이 가능해 자원을 절약할 수 있다.

- PC에서는 별다른 설정이 필요 없지만 스위치에서 TRUNK 모드를 활성화 하고 VLAN을 정의하는 등의 설정 작업이 필요하단 것을 이해했다.

## 오늘 헷갈린 점

- 처음에 케이블을 Cross가 아니라 정 케이블로 연결해서 오류가 발생했다.

- 자동 연결 아이콘으로 연결해서 24-24끼리 연결이 되지 않고 3-3으로 연결되서 오류가 발생했다.