terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "lopapadancesfor.us"

  tags = {
    project = "lopapadancesfor.us"
  }
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_logging" "bucket" {
  bucket        = aws_s3_bucket.bucket.id
  target_bucket = "logs.617211123486"
  target_prefix = "lopapadancesfor_us/"
}

data "cloudflare_ip_ranges" "cloudflare" {
}

resource "aws_s3_bucket_policy" "allow_website_access" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_website_access.json
}

data "aws_iam_policy_document" "allow_website_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.cloudflare_ip_ranges.cloudflare.ipv4_cidrs
    }

  }
}
