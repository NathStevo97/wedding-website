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

### Variables

| Variable Name    | Description                                           | Example Value |
|------------------|-------------------------------------------------------|---------------|
| `region`         | The AWS deployment region                             | `us-east-1`   |
| `domain_name`    | Website Domain Name                                   | `example.com` |
| `hosted_zone_id` | AWS Route53 Hosted one ID                             |               |
| `site_password`  | Password for access to `index.html` from `login.html` | `password`    |

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
