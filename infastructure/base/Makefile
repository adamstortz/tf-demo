environment = dev

.PHONY: fmt
fmt: ## Rewrites config to canonical format
	@terraform fmt

.PHONY: lint
lint: ## Lint the Terraform code
	terraform fmt -diff=true -check

.PHONY: validate
validate: ## Basic syntax check
	@terraform validate

.PHONY: show
show: ## List infra resources
	@terraform show

.PHONY: refresh
refresh: ## Refresh infra resources
	@terraform refresh -var-file=”prod.tfvars”

.PHONY: console
console: ## Console infra resources
	@terraform console

.PHONY: init
init: ## Initialize Terraform
	@terraform init

.PHONY: workspace
workspace: ## Workspace infra resources
	@terraform workspace

.PHONY: plan
plan: ## Plan resource changes
	echo $(AWS_ACCESS_KEY_ID)
	terraform plan -var-file=$(environment).tfvars

.PHONY: apply
apply: ## Apply resource changes
	@terraform apply

.PHONY: destroy
destroy: ## Destroy resources
	@terraform destroy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help