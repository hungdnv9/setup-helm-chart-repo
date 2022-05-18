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

// Github Action 
// Required: Created an IAM user, called: github-action-helm-chart-repo

resource "aws_iam_policy" "github_action" {
  name        = "github-action-helm-chart-repo-policy"
  path        = "/"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "files",
                "Effect": "Allow",
                "Action": [
                    "s3:PutObjectAcl",
                    "s3:PutObject",
                    "s3:GetObjectAcl",
                    "s3:GetObject",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::${aws_s3_bucket.helm_repo.id}/charts/*",
                    "arn:aws:s3:::${aws_s3_bucket.helm_repo.id}/charts"
                ]
            },
            {
                "Sid": "bucket",
                "Effect": "Allow",
                "Action": "s3:ListBucket",
                "Resource": "arn:aws:s3:::${aws_s3_bucket.helm_repo.id}"
            }
        ]
    }
  )
}

resource "aws_iam_policy_attachment" "github_action" {
  name       = "github-action-helm-chart-repo-policy"
  users      = ["github-action-helm-chart-repo"]
  policy_arn = aws_iam_policy.github_action.arn
}
