terraform {
  required_version = ">= 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.89.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    template = {
      source  = "hashicorp/template"
      version = ">=2.2.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

provider "null" {
  # Configuration options
}