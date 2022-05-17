terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "local" {}
}

provider "aws" {}

data "aws_caller_identity" "current" {}


// Create a unique S3 bucket.
resource "aws_s3_bucket" "helm_repo" {
  bucket = "helm-repository-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_acl" "helm_repo" {
  bucket = aws_s3_bucket.helm_repo.id
  acl    = "private"
}


// In the bucket, create 2 folders called: charts/
resource "aws_s3_object" "charts" {
  bucket = aws_s3_bucket.helm_repo.id
  key    = "charts/"
}
