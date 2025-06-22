# Chloe & Nathan's Wedding Website

Repository to house code for hosting and deploying the wedding website for myself and my lovely fiancee / soon-to-be-wife.

## Website

The website consists of 2 pages, one used to control access, and another for the main site content. Users are directed to `login.html` if not authenticated, and granted access to `index.html` upon success.

User flow can be simulated locally, create `config.json` locally and add `auth_password` in a similar manner to below

```json
{
    "auth_password": "<password>"
  }

```

You can then run `node local_server.js` to similar the user workflow, which will pass `auth_password` in.

## Infrastructure

The website's infrastructure is hosted on AWS and managed by Terraform. The website files are hosted within two S3 buckets and made available via Cloudfront. One each for the `www.` and non-`www.` prefixed domain.

### Prerequisites

- An AWS Route 53 Hosted Zone
- A valid domain name

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.3 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >=2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificate"></a> [certificate](#module\_certificate) | ./modules/certificate | n/a |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ./modules/cloudfront | n/a |
| <a name="module_route53"></a> [route53](#module\_route53) | ./modules/route53 | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ./modules/S3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.CachingOptimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The S3 Bucket Name/Domain Name | `string` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | The Hosted Zone Id of the domain | `string` | n/a | yes |
| <a name="input_site_password"></a> [site\_password](#input\_site\_password) | Password for protecting the static website | `string` | n/a | yes |
| <a name="input_website_static_dir"></a> [website\_static\_dir](#input\_website\_static\_dir) | Path to the root directory of website static content | `string` | `"../site"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_domain"></a> [bucket\_domain](#output\_bucket\_domain) | The domain name of the S3 bucket for static website hosting. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the S3 bucket created for static website hosting. |
| <a name="output_cloudfront_distribution_domain"></a> [cloudfront\_distribution\_domain](#output\_cloudfront\_distribution\_domain) | The domain name of the CloudFront distribution. |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | The ID of the CloudFront distribution created for the S3 bucket. |
<!-- END_TF_DOCS -->

### Deployment

The infrastructure can be deployed from the `infra` directory and utilising the provided `Makefile`.

```shell
cd infra
make build-site
```

Tearing down the infrastructure can be achieved by the same `Makefile`:

```shell
make destroy-site
```
