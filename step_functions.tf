resource "aws_dynamodb_table" "lock_table" {
  name         = "${local.stack_name}-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_iam_role" "step_functions_role" {
  name = local.stack_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.${var.aws_region}.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "step_functions_policy" {
  name        = local.stack_name
  description = "Permissions for Step Functions to access DynamoDB and Auto Scaling"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowDynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.lock_table.arn
      },
      {
        Sid    = "AllowAutoScalingAccess"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_role_policy_attachment" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_policy.arn
}

resource "aws_cloudwatch_log_group" "step_functions_log_group" {
  name              = "/aws/states/${local.stack_name}"
  retention_in_days = 14
}

resource "aws_sfn_state_machine" "state_machine" {
  name     = local.stack_name
  role_arn = aws_iam_role.step_functions_role.arn

  definition = templatefile("templates/state_machine_scale_out.json", {
    gitlab_secret_token     = var.gitlab_secret_token,
    dynamodb_table_name     = aws_dynamodb_table.lock_table.name,
    auto_scaling_group_name = local.stack_name
  })
}
