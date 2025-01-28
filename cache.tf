resource "aws_s3_bucket" "gitlab_cache" {
  bucket = local.stack_name
}

data "aws_iam_policy_document" "gitlab_cache" {
  statement {
    effect = "Allow"
    actions = [
      "kms:GetPublicKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucket",
      "s3:ListMultipartUploadParts",
    ]
    resources = [
      "${aws_s3_bucket.gitlab_cache.arn}/*",
      aws_s3_bucket.gitlab_cache.arn,
    ]
  }
}

resource "aws_iam_policy" "gitlab_cache_policy" {
  name   = "gitlab-cache-${local.stack_name}"
  policy = data.aws_iam_policy_document.gitlab_cache.json
}

data "aws_iam_policy_document" "gitlab_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

# resource "aws_iam_role" "gitlab_role" {
#   name               = "gitlab-role-${local.stack_name}"
#   assume_role_policy = data.aws_iam_policy_document.gitlab_assume_role_policy.json
# }

resource "aws_iam_role_policy_attachment" "gitlab_policy_attachment" {
  policy_arn = aws_iam_policy.gitlab_cache_policy.arn
  role       = var.iam_role
}
