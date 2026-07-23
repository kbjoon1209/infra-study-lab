# GitHub Actions Deployment Artifact Upload to S3

## 목적

GitHub Actions에서 검증·Build한 배포 Package를
OIDC IAM Role을 이용해 Private S3 Bucket에 업로드한다.

S3에 업로드한 파일을 다시 다운로드하여
SHA256 Checksum과 Archive 내용을 검증한다.

---

## 전체 흐름

```text
GitHub Actions
↓
Static Site Validation
↓
tar.gz + SHA256 Build
↓
OIDC Authentication
↓
IAM Role Permission
↓
Private S3 Bucket Upload
↓
Download
↓
SHA256 Verification
```

---

## S3 Bucket

- Bucket Name: 마스킹
- Region: 아시아 태평양(서울) ap-northeast-2
- Block Public Access: enable
- Object Ownership: 버킷 소유자 적용
- Versioning: enable
- Default Encryption: Amazon S3 SSE-S3
- Static Website Hosting: disable

---

## GitHub Repository Variable

- Variable Name: AWS_DEPLOY_BUCKET
- Value: bj-infra-deploy-artifacts-3f6272e0
- Secret 여부: no

---

## Workflow

- Workflow Name: Upload Deployment Package to S3
- Trigger: workflow dispatch 수동실행
- Runner: ubuntu-latest
- Checkout Action: actions/checkout@v6
- Credential Action: aws-actions/configure-aws-credentials@v6
- Source: migration/source-site
- Build Output: dist/
- S3 Prefix: deployments/${{ github.sha }}

---

## Permission Policy 추가 전

- OIDC Authentication: Success
- Caller Identity: Success
- S3 Upload: Failed
- Error: AccessDenied
- Workflow Result: Failure

---

## IAM Permission Policy

- Policy Name: bj-github-s3-deploy-policy
- 허용 Bucket: bj-infra-deploy-artifacts-3f6272e0
- 허용 Prefix: deployments/*
- Bucket 권한: 
    - s3:GetBucketLocation
    - s3:ListBucket
- Object 권한:
    - s3:PutObject
    - s3:GetObject
- Delete 권한: 없음
- Bucket 설정 변경 권한: 없음

---

## Permission Policy 추가 후

- Workflow Result: Success
- S3 Upload: Success
- S3 Object List: Success
- Download: Success
- SHA256: Success
- Archive 내용: Success

---

## S3 Object

- `build-info.txt`: 패키지를 생성한 버전, SHA와 빌드 시간 기록
- `static-site-*.tar.gz`: 
    index.html, health.txt가 포함된 배포 패키지
- `static-site-*.tar.gz.sha256`:
    압축 파일의 무결성 확인하기 위한 SHA256 체크섬 파일

---

## Trust Policy와 Permission Policy

- Trust Policy: 누가 Role을 빌릴 수 있는가?
- Permission Policy: Role으로 무엇을 허용할 것인가?

---

## 내가 이해한 내용

- AWS S3에서 Buckect을 하나 만들었으며, Bucket은 일종의 구글 드라이브와 같은 저장소 클라우드면서 정적 호스팅도 가능한 역할을 담당한다고 이해했다.

- WSL2 우분투에서 S3 Bucket으로 배포하는 github action workflow를 작성했다.

- 처음에는 IAM에서 권한 정책을 수행하지 않고 run workflow를 했으나 S3에 업로드 하는 과정에서 권한 관련 오류가 발생했다.

- AWS IAM Role에서 권한을 Bucket의 deployments/*만 사용하는 권한을 추가하자 정상적으로 작업을 완료했다.

## 오늘 헷갈린 점

- githubaction의 setting에서 variable을 왜 추가했는지 여전히 잘 이해하지 못하겠다.

- 흐름은 이해했지만 세세한 배포 과정은 헷갈렸다.