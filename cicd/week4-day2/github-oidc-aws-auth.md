# GitHub Actions OIDC and AWS IAM Role Authentication

## 목적

GitHub Actions에서 장기 AWS Access Key를 저장하지 않고,
OIDC와 IAM Role을 이용해 임시 AWS 자격증명을 발급받는다.

---

## 전체 흐름

```text
GitHub Actions
↓
OIDC Token
↓
AWS IAM OIDC Provider
↓
IAM Role Trust Policy
↓
STS Temporary Credentials
↓
get-caller-identity
```

---

## OIDC Provider

- Provider Type: OpenID connect
- Provider URL: https://token.actions.githubusercontent.com
- Audience: sts.amazonaws.com

---

## IAM Role

- Role Name: bj-github-oidc-auth-role
- Trusted Provider: arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com
- Audience: `sts.amazonaws.com`
- Audience: sts.amazonaws.com
- 허용 Repository: kbjoon1209/infra-study-lab
- 허용 Branch: main
- Permission Policy: 없음

---

## Trust Policy 조건

- `aud`: sts.amazonaws.com
- `sub`: repo:kbjoon1209/infra-study-lab:ref:refs/heads/main
- 허용 Subject:
    infra-study-lab Repository의 main Branch에서 실행된 GitHub Actions Workflow

---

## GitHub Repository Variable

- Variable Name: AWS_OIDC_ROLE_ARN
- Value Type: GitHub Actions Repository Variable
- Value: arn:aws:iam::<ACCOUNT_ID>:role/bj-github-oidc-auth-role
- AWS Access Key 저장 여부: 저장 안 함

---

## Workflow

- Workflow Name: AWS OIDC Authentication
- Trigger: run workflow로 수동 실행
- Runner: ubuntu-latest
- AWS Region: ap-northeast-2
- Credential Action: aws-actions/configure-aws-credentials@v6
- `id-token` Permission: write
- Account ID Masking: true

---

## main Branch 인증 결과

- Workflow Result: Success
- Configure Credentials: Success
- Caller Identity: 확인
- Assumed Role: success
- Exit Result: Success

---

## Branch 제한 검증

- 테스트 Branch: oidc-deny-lab
- Workflow Result: Failure
- 실패 Step: Configure temporary AWS credentials
- 실패 원인: AWS IAM Role에서 신뢰관계에 main branch만 허용하고 있어서 실패함.

---

## 복구 확인

- 실행 Branch: main
- Workflow Result: success
- Caller Identity: bj-github-oidc-auth-role을 사용한 Assumed Role 확인

---

## Trust Policy와 Permission Policy

- Trust Policy: 누가 role을 빌릴 수 있는가?를 결정한다.
- Permission Policy: role을 빌려서 뭘 할 수 있는가를 결정한다.

---

## 내가 이해한 내용

- AWS IAM에서 ROLE과 ID 제공업체를 추가했고 github action이 AWS에 접근할 수 있도록 임시 키?와 비슷한 자격증명을 얻는 과정을 진행했다.

- IAM ROLE에서는 신뢰관계(Trust Policy)만 있고 권한(Permission)은 설정하지 않았다.

- gitaction에서 run workflow를 실행해야 정상적으로 aws에 접근 할 수 있다는 것을 이해했다.

- 임시로 oidc-deny-lab branch를 만들어서 수동으로 workflow를 실행하자 AWS 자격증명 구성 과정에서 오류가 발생했고 다시 git main으로 branch를 바꿔서 run하자 정상적으로 동작하는 것을 검증했다.

## 오늘 헷갈린 점

- CD의 기본이 되는 과정이라고 이해했고 대강의 흐름은 잡았지만 아직도 세부적인 사항은 궁금증이 남는다.

- 이전까지는 WSL2 내부 AWS 내부에서 한 번에 벌어지는 작업이었는데 4주차부터는 github 사이트, aws console, 내 wsl2 ubuntu까지 열어두면서 왔다갔다 하면서 작업을 하니 꽤나 복잡했다.

- main만 허용했다는 건 알았는데 어디서 그걸 설정했는 지 잘 모르겠다.