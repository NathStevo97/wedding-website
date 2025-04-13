build-site:
	terraform apply --auto-approve

destroy-site:
	terraform destroy --auto-approve

rebuild-site: destroy-site build-site

secure-lint:
	terraform fmt -check=true
	terraform validate
	tflint
	docker run -t -v .:/tf --workdir /tf bridgecrew/checkov --directory /tf --quiet