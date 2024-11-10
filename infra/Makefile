build-site:
	terraform apply --auto-approve
	aws s3 cp ../site s3://chloeandnathan.com --recursive
	aws s3 cp ../site s3://www.chloeandnathan.com --recursive

destroy-site:
	terraform destroy --auto-approve