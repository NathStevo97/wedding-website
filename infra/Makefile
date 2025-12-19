build-site:
	terraform apply --auto-approve

destroy-site:
	terraform destroy --auto-approve

rebuild-site: destroy-site build-site

test-site: build-site destroy-site

secure-lint:
	terraform fmt -recursive -check=true ./
	terraform validate
	tflint
	checkov -d .