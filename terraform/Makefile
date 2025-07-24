.PHONY: init plan apply destroy fmt validate

ENV ?= dev

init:
	terraform init

plan:
	terraform plan -var-file=environments/$(ENV)/terraform.tfvars

apply:
	terraform apply -var-file=environments/$(ENV)/terraform.tfvars

destroy:
	terraform destroy -var-file=environments/$(ENV)/terraform.tfvars

fmt:
	terraform fmt -recursive

validate:
	terraform validate

# Build and push Docker image to GCR
build:
	gcloud builds submit --tag gcr.io/lucitra-ai/lucitra-webhook-server:latest ..

# Deploy to specific environment
deploy-dev:
	$(MAKE) build
	$(MAKE) apply ENV=dev

deploy-prod:
	$(MAKE) build
	$(MAKE) apply ENV=prod

# Show outputs
output:
	terraform output -json