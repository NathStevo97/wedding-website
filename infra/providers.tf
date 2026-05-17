terraform {
  required_version = ">= 1.11.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.45.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.3.0"
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

provider "null" {
  # Configuration options
}
