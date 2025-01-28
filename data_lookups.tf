data "aws_ami" "gitlab_runner" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = [var.image_name]
  }

}

# data "aws_caller_identity" "current" {}

data "aws_default_tags" "tags" {}

# data "aws_iam_role" "gitlab_runner" {
#   name = var.iam_role
# }

# data "aws_kms_key" "platform_services" {
#   key_id = "alias/platform-services-kms-tooling"
# }
