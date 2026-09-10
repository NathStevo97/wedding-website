TF_DIR := terraform


init-site:
	cd $(TF_DIR) && terraform init -upgrade

validate-site:
	cd $(TF_DIR) && terraform validate

plan-site:
	cd $(TF_DIR) && terraform plan

build-site:
	cd $(TF_DIR) && terraform apply --auto-approve

destroy-site:
	cd $(TF_DIR) && terraform destroy --auto-approve

rebuild-site: destroy-site build-site

test-site: build-site destroy-site

secure-lint:
	terraform fmt -recursive -check=true ./
	terraform validate
	tflint
	checkov -d .

build-site-docker:
	docker build -t wedding-website:latest .

run-site-docker:
	docker run -p 8080:80 -d --name wedding-website wedding-website:latest
