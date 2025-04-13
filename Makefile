build-site:
	cd infra
	terraform apply --auto-approve
	cd ../

destroy-site:
	cd infra
	terraform destroy --auto-approve
	cd ../

rebuild-site: destroy-site build-site

secure-lint:
	cd ./infra
	terraform fmt -check=true
	terraform validate
	tflint
	docker run -t -v .:/tf --workdir /tf bridgecrew/checkov --directory /tf --quiet
	cd ../