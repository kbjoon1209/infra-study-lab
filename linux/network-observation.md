# Linux Network Observation

## 목적

Linux 환경에서 실제 Network Interface, IP Address,
Routing Table, Default Gateway, TCP/UDP Socket,
Neighbor 정보를 확인한다.

## 확인 명령

```bash
ip -br addr
ip addr
ip route
ip neigh
ss -lntp
ss -lunp
```

## 실제 확인 결과

Interface: eth0

IPv4: 172.29.35.79/20

Prefix: /20

Default Gateway: 172.29.32.1

TCP Listener: 53, 80, 36749, 35781

UDP Socket: 53, 323

Neighbor: 
172.29.32.1 dev eth0
lladdr 00:15:5d:be:5b:05
REACHABLE

## 내가 이해한 내용

- 오늘은 Linux의 각종 네트워크 명령어를 통해서 IP 주소, GATEWAY, DNS, TCP, UDP, MAC를 확인했다.
- IP -br addr은 간략하게 IPv4 주소와 IPv6 주소를 네트워크 인터페이스 별로 확인할 수 있었다.
- WSL 우분투 환경의 eth0 네트워크 인터페이스에 할당된 MAC 주소를 확인했다. 
- 실제 windows host의 물리 nic 주소는 별개로 존재한다.
- ping 127.0.0.1이라는 명령어를 통해 외부 네트워크를 거치지 않고 자기 자신의 loofback interface 정상적인 지 확인 후 ip route get 8.8.8.8을 통해 리눅스 커널이 해당 목적지까지 게이트웨이 주소 -> 물리적 장비 eth0으로 나가며, 172.29.35.79 소스 ip 주소를 선택하는 것을 확인했다.
- 게이트웨이 주소로 ping을 보내서 정상적으로 라우터 주소까지 통신이 되는 지 확인했다.

## 오늘 헷갈린 점

- 기사 자격증 공부 이후에 오랜만에 CIDR 표기법을 다시 만났다. 공부 당시 10시간 가까이 할당해서 서브네팅과 CIDR 계산법, A-D클래스까지 공부했지만 벌써 3달 가까이 지나서 기억에서 소거되서 복습하면서 다시 CIDR 표기법을 공부했다.
- 172.29.35.79/20은 B클래스에 속한다. 그리고 IPv4는 32비트, 좌측 20비트는 NETWORK IP, 우측 12비트는 HOST IP로 구성하며, 해당 IP는 8 / 8 / 8 / 8에서 3번째 칸을 할당하고 있는데 /20 -> 20-16 = 4, 즉 NETWORK는 4비트를 할당해서 2의 4승 = 16을 0~15 / 16 ~ 31 이런식으로 구성한다. 즉, 올바른 게이트웨이 주소는 172.29.32.1이지만 나는 처음에 172.29.35.1로 계산했다.
- 게이트웨이와 라우터 주소의 개념이 헷갈려서 인터넷 검색을 통해 다시 개념을 정립했다. 게이트웨이는 외부 네트워크와 통신할 때 지나는 출구, 라우터는 외부 네트워크를 IP 주소를 기반으로 경로를 찾아가는 역할을 하며, 라우터 주소=게이트웨이 주소가 같나 헷갈렸다.

## 오늘의 한 문장 요약

- 리눅스에서 ip addr, ip route, ip neigh, ss 명령을 사용해 Network Interface와 IP Address, Routing Table, Default Gateway, Neighbor의 IP-MAC 관계, TCP/UDP Socket 상태를 확인하고, ping과 ip route get으로 Loopback·Gateway 응답 및 특정 목적지에 대한 Route 선택을 검증했다.