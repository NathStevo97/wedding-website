terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.67.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-west-2"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

provider "null" {
  # Configuration options
}