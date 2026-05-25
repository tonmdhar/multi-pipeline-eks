terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state in S3 — keeps state safe + enables team collaboration
  backend "s3" {
    bucket         = "atlas-platform-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "atlas-platform-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "staging"
      MangedBy    = "terraform"
      Project     = "atlas-platform"
    }
  }
}
}
