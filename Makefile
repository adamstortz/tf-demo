.PHONY: fmt
fmt: ## Rewrites config to canonical format
	(cd infastructure/base; make fmt)
	(cd infastructure/workload; make fmt)

.PHONY: lint
lint: ## Lint the HCL code
	(cd infastructure/base; make lint)
	(cd infastructure/workload; make lint)

.PHONY: validate
validate: ## Basic syntax check
	(cd infastructure/base; make validate)
	(cd infastructure/workload; make validate)

.PHONY: show
show: ## List infra resources
	(cd infastructure/base; make show)
	(cd infastructure/workload; make show)

.PHONY: refresh
refresh: ## Refresh infra resources
	(cd infastructure/base; make refresh)
	(cd infastructure/workload; make refresh)

.PHONY: init
init: ## Initialize Terraform
	(cd infastructure/base; make init)
	(cd infastructure/workload; make init)

.PHONY: plan
plan: install ## Plan resource changes
	(cd infastructure/base; make install)
	(cd infastructure/workload; make install)

.PHONY: apply
apply: ## Apply resource changes
	(cd infastructure/base; make apply)
	(cd infastructure/workload; make apply)

.PHONY: deploy
deploy: ## Deploy base infrastructure, build and push docker image, deploy workload infrastructure
	(cd infastructure/base; make apply)
	(cd infastructure/workload; make apply)

.PHONY: destroy
destroy: ## Destroy resources
	(cd infastructure/base; make destroy)
	aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
	docker build -t "${aws_ecr_repository.tf_demo_service.repository_url}:latest" -t "${aws_ecr_repository.tf_demo_service.repository_url}:${var.image_version}" -f service/src/Dockerfile service/src/
	docker push "${aws_ecr_repository.tf_demo_service.repository_url}:latest"
	docker push "${aws_ecr_repository.tf_demo_service.repository_url}:${var.image_version}"
	(cd infastructure/workload; make destroy)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help