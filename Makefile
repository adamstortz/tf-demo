GET_ACCOUNT_NUMBER = $(eval ACCOUNT_NUMBER=$(shell aws sts get-caller-identity --query "Account" --output text))
GET_ECR_URL = $(eval ECR_URL=$(shell terraform -chdir=infastructure/base output -raw ecr_url))
GET_LB_HOST_NAME = $(eval LB_HOST_NAME=$(shell terraform -chdir=infastructure/workload output -raw load_balancer_name))

.PHONY: fmt
fmt: ## Rewrites config to canonical format
	@(cd infastructure/base; make fmt)
	@(cd infastructure/workload; make fmt)

.PHONY: lint
lint: ## Lint the HCL code
	@(cd infastructure/base; make lint)
	@(cd infastructure/workload; make lint)

.PHONY: validate
validate: ## Basic syntax check
	@(cd infastructure/base; make validate)
	@(cd infastructure/workload; make validate)

.PHONY: show
show: ## List infra resources
	@(cd infastructure/base; make show)
	@(cd infastructure/workload; make show)

.PHONY: refresh
refresh: ## Refresh infra resources
	@(cd infastructure/base; make refresh)
	@(cd infastructure/workload; make refresh)

.PHONY: init
init: ## Initialize Terraform
	@(cd infastructure/base; make init)
	@(cd infastructure/workload; make init)
	@(npm install)

.PHONY: test
test: ## Initialize Terraform
	$(GET_LB_HOST_NAME)
	@(npm run test:unit)
	@(LB_HOST_NAME=$(LB_HOST_NAME) npm run test:integration)

.PHONY: plan
plan: ## Plan resource changes
	@(cd infastructure/base; make plan)
	@(cd infastructure/workload; make plan)

.PHONY: apply
apply: ## Apply resource changes
	@(cd infastructure/base; make apply)
	@(cd infastructure/workload; make apply)

.PHONY: deploy_base
deploy_base: ## Deploy base infrastructure, build and push docker image, deploy workload infrastructure
	$(GET_ACCOUNT_NUMBER)
	@(cd infastructure/base && \
	  make deploy)

.PHONY: deploy_workload
deploy_workload: ## Build and push docker image, deploy workload infrastructure
	$(GET_ACCOUNT_NUMBER)
	$(GET_ECR_URL)
	@(image_version=$$RANDOM && \
	  aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ACCOUNT_NUMBER).dkr.ecr.$(AWS_REGION).amazonaws.com && \
	  echo $(ECR_URL) && \
	  docker build -t "$(ECR_URL):latest" -t "$(ECR_URL):$${image_version}" -f service/src/Dockerfile service/src/ && \
	  docker push "$(ECR_URL):latest" && \
	  docker push "$(ECR_URL):$${image_version}" && \
	  cd infastructure/workload && \
	  make deploy -e image_version=$${image_version})

.PHONY: destroy
destroy: ## Destroy resources
	@(cd infastructure/workload; make destroy)
	@(cd infastructure/base; make destroy)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help