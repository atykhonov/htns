ifneq (,$(wildcard ./.env))
	include .env
	export
endif

.PHONY: run build setup deploy clean

run: build_with_docker deploy

build:
	@sam build

build_with_docker:
	@sam build --use-container

build_layers:
	@sam build AxiosLib

test_env_variables:
	@test -n "$(AWS_REGION)" || (echo "AWS_REGION not set" ; exit 1)
	@test -n "$(S3_BUCKET)" || (echo "S3_BUCKET not set" ; exit 1)
	@test -n "$(STACK_NAME)" || (echo "STACK_NAME not set" ; exit 1)
	@test -n "$(STAGE)" || (echo "STAGE not set" ; exit 1)

test_sam_params_file:
	@test -f .sam-params || (echo ".sam-params doesn't exist"; exit 1)

deploy: test_env_variables test_sam_params_file build
	@aws --region $(AWS_REGION) s3 ls s3://$(S3_BUCKET) || aws --region $(AWS_REGION) s3 mb s3://$(S3_BUCKET)
	@echo "STAGE: $(STAGE)"
	@echo "AWS_REGION: $(AWS_REGION)"
	@echo "STACK_NAME: $(STACK_NAME)"
	@sam deploy --stack-name $(STACK_NAME) \
		--s3-bucket $(S3_BUCKET) \
		--s3-prefix $(S3_PREFIX) \
		--capabilities 'CAPABILITY_IAM' \
		--region $(AWS_REGION) \
		--no-confirm-changeset \
		--parameter-overrides $(shell cat .sam-params)

clean:
	@aws cloudformation delete-stack --stack-name $(STACK_NAME)

logs-event-handler:
	@sam logs --stack-name $(STACK_NAME) --name DripService --region $(AWS_REGION) -t
