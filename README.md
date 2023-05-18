# tf-demo

## Prerequisites

- Tools
  - AWS CLI
  - Docker
  - Terraform
  - Make
- Environment Variables:
  - AWS_REGION
- Choose a bucket name - `BUCKET_NAME`
- Create an AWS S3 bucket in the us-east-2 region with the name and versioning enabled
- Update all instances of `bucket = "tf-demo-astortz"` to `bucket = "BUCKET_NAME"` 
- If running from GitHub Actions
  - configure [OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
  - Add a repo secret named `AWS_ACCOUNT_ID`
- Update `kms_key_administrators` in `infrastructure/workload/main.tf` list to include your role

## Deploy and test

```bash
# Initialize codebase
make init
# Deploy
make deploy_base deploy_workload
# Test
make test
```
