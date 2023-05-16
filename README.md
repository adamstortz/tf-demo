# tf-demo

## Prerequisites

- Tools
  - AWS CLI
  - Docker
  - Terraform
  - Make
- Environment Variables:
  - AWS_REGION
- AWS
  - S3 bucket
    - name: tf-demo-astortz
    - region: us-east-2
    - versioning: enabled
  - https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

## Execution

```bash
# Initialize codebase
make init
# Deploy
make deploy
```