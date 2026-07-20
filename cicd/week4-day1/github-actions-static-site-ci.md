# GitHub Actions Static Site CI

## 목적

Git Push를 기준으로 GitHub Actions Workflow를 실행하여
Static Site의 파일과 HTTP 응답을 검증한다.

검증이 성공하면 EC2 배포에 사용할 tar.gz Package와
SHA256 Checksum을 생성하고 GitHub Artifact로 보관한다.

---

## 전체 흐름

```text
Git Push
↓
GitHub Actions Runner
↓
Bash Syntax Check
↓
Static File Validation
↓
Temporary HTTP Test
↓
tar.gz Build
↓
SHA256 Verification
↓
Artifact Upload
```

---

## Source

| File | 역할 |
|---|---|
| `index.html` | 배포할 Static Web Page |
| `health.txt` | 배포·서비스 상태 확인 문자열 |

---

## Validation Script

- Script: validate-static-site.sh
- Source Directory: migration/source-site
- 검사한 File: 'health.txt', 'index.html'
- HTML Title 결과: OK
- Health Content 결과: OK
- Temporary HTTP `/`: response validated
- Temporary HTTP `/health.txt`: response validated
- Exit Code: 0

---

## Build Script

- Script: build-static-site.sh 
- Archive: dist/static-site-ca68ecc65099.tar.gz
- Archive 내용: 'health.txt', 'index.html'
- SHA256 결과: 성공
- Build Info: build-info.txt

---

## GitHub Actions Workflow

- Workflow: Static Site CI
- Trigger:
  - Push: main, ci-failure-lab
  - Pull Request: main
  - Manual: workflow_dispatch
- Runner: ubuntu-latest
- Checkout Action: actions/checkout@v7
- Artifact Action: action/upload-artifact@v7
- Timeout: 10 minutes
- Permission: read

---

## 최초 CI 결과

- Workflow Result: success
- Validation: all complete job
- Build: BUILD SUCCESS
- Checksum: static-site-40a36e764307.tar.gz: 
- Artifact: static-site-40a36e764307045458ee58a8ac0f5471d4ea01a8
- Artifact Download 후 Checksum: sha256sum -c 결과 OK

---

## 실패 재현

- 변경 내용: migration/source-site/health.txt 내용을 BROKEN~으로 변경 후 GIT BRANCH를 ci-failure-lab으로 switch 후 git push
- 실패 Step: Validate static site
- Error: Process completed with exit code 1.
- Workflow Result: Failure

---

## 복구

- 복구 내용:  migration/source-site/health.txt 내용을 main branch의 정상 내용으로 복구
- Validation: all complete job
- Workflow Result: success

---

## CI와 CD 구분

- 오늘 완료한 CI:
 - git push를 trigger로 github action workflow를 실행했다.
 - bash, static file, http 응답을 검증했다.
 - 검증에 성공하면 tar.gz와 sha256 checksum을 생성하고 github action artifact에 업로드 했다.
 - 검증에 실패하면 빌드와 artifact 업로드를 진행하지 않도록 했다.
- 다음 단계의 CD: CI의 산출물을 AWS의 실제 배포 위치로 전달하는 것으로 추측한다.

---

## 내가 이해한 내용

- git push를 하면 github actions가 자동으로 index.html과 health.txt를 검사하도록 설정했다.

- 검증에 성공하면 파일을 압축해서 sha256로 확인 후 artifact로 저장했다.

- healt.txt가 내용이 잘못되면 workflow가 실패하고 정상으로 복구하니까 성공하는 것을 검증했다.

- 오늘은 자동 검출과 최종 산출 파일(배포용) 생성까지 했고 다음 단계에서는 ec2에 자동 배포를 한다고 이해했다.

## 오늘 헷갈린 점

- 절대경로와 상대경로가 헷갈려서 /tmp가 루트 디렉토리 기준인 것을 생각하지 못하고 aws-rehost... 이곳에 tmp를 만들어서 실패하는 등 실수를 했다.

- .sh의 코드가 여전히 이해하기 어려웠다.